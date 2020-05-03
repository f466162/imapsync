#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

function doSync() {
	imapsync                                 \
	  --host1 ${HOST1}                       \
	   --tls1                                \
	   --user1 ${USER1}                      \
	   --passfile1 ${PASS1}                  \
	   --folder INBOX                        \
	   --delete1                             \
	  --host2 ${HOST2}                       \
	   --tls2                                \
	   --user2 ${USER2}                      \
	   --passfile2 ${PASS2}                  \
	  --pidfile $HOME/imapsync.pid           \
	  --tmpdir $HOME/tmp                     \
	  --noexpungeaftereach                   \
	  --usecache                             \
	  --no-modulesversion                    \
	  --nofoldersizes                        \
	  --nofoldersizesatend                   \
         > $LOGFILE 2>&1
}

# We stay in background
renice -n 19 $$ > /dev/null

# Just exit in case of signals
trap 'exit 0' SIGTERM
trap 'exit 0' SIGKILL

# Control loop
while true
do
	# Account loop
	for i in $HOME/*.conf
	do
		# Might happen in case of an empty volume or wrong permissions
		if ! [ -r "$i" ]
		then
			>&2 echo Error reading configuration from $i
			exit 1
		fi

		# Load config file
		. ${i}

		# Determine log file
		export LOGFILE=$HOME/`basename ${i} .conf`.log

		# Clean old log
		truncate -s 0 ${LOGFILE}

		echo INFO: Sync startet for ${i}

		doSync || {
			errorlog=${LOGFILE}.$$.`date +%s`
			>&2 echo An error occured for ${i}, see ${errorlog}

			cp $LOGFILE ${errorlog}

			exit 1
		}

		egrep "^(Transfer time|Folders synced|Messages transferred)" $LOGFILE
		echo INFO: Sync ended for ${i}
	done

	# Wait for next sync
	sleep $(((RANDOM % 1337) + 60))
done

