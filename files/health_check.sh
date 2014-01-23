#!/bin/bash

#check IB link
IBSTAT=`which ibstat 2> /dev/null`

if [ -e "${IBSTAT}" ];then
 IBCHK=`ibstat | grep LinkUp | wc -l`
 IBEXISTS=`ibstat`
 if [ -n "${IBEXISTS}" -a "${IBCHK}" -lt "1" ];then
  echo "ERROR Infiniband link down (check ibstat)"
 fi
fi

#TODO: change these to some ib IPs of noncompute nodes with ib
ping -q -c 1 -w 1 172.30.129.0 >/dev/null 2>&1
h=$?
ping -I ib0 -q -c 1 -w 1 172.30.128.254 >/dev/null 2>&1
s=$?
if [ $h -ne 0 -a $s -ne 0 ]
then
        echo "ERROR cannot ping nodes over IB network"
        exit
fi

#check NFS mounts: /home
if [ -z "`mount | grep /home`" ]
then
        echo "ERROR /home not mounted"
        exit
fi

#check NFS mounts: /opt
if [ -z "`mount | grep /opt`" ]
then
        echo "ERROR /opt not mounted"
        exit
fi

#check NFS mounts: /usr/local
if [ -z "`mount | grep /usr/local`" ]
then
        echo "ERROR /usr/local not mounted"
        exit
fi

#TODO: make sure these files exist
#check /home read
if [ ! -f /home/test/do_not_delete ]
then
        echo "ERROR cannot read /home"
        exit
fi

#check /opt read
if [ ! -f /opt/scripts/mount_lustre.sh ]
then
	echo "ERROR cannot read /opt"
	exit
fi

#check /usr/local read
if [ ! -d /usr/local/software ]
then
	echo "ERROR cannot read /usr/local"
	exit
fi

#check Lustre mount
if [ -f /opt/scripts/lustre_up ]
then
        if [ -z "`mount | grep /lustre`" ]
        then
                echo "ERROR /lustre not mounted"
                exit
        fi

        if [ "`cat /lustre/test/do_not_delete`" != "used in health checking" ]
        then
                echo "ERROR cannot read /lustre"
                exit
        fi
fi

