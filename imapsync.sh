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

trap 'exit 0' SIGTERM
trap 'exit 0' SIGKILL

while true
do
	for i in $HOME/*.conf
	do
		if ! [ -r "$i" ]
		then
			>&2 echo Fehler beim Einlesen von $i
			exit 1
		fi

		. $i
		export LOGFILE=$HOME/`basename $i .conf`.log

		echo INFO: Start $i

		doSync || {
			>&2 echo Fehler bei $i aufgetreten
			cp $LOGFILE $LOGFILE.$$.`date +%s`		
			exit 1
		}

		egrep "^(Transfer time|Folders synced|Messages transferred)" $LOGFILE
		echo INFO: Ende $i
	done

	sleep $(((RANDOM % 1337) + 60))
done

