#!/bin/sh
#ideas taken from http://www.gentoo-wiki.info/HOWTO_Setup_2_Node_Active_Passive_Cluster_With_DRBD_UCARP

log()
{
	logger -t carp-vip-down "$*"
}

#TODO: adjust eth interface to your needs
umount /lustre && log "lustre umount ok" || log "lustre umount failed"
/usr/sbin/lustre_rmmod >/dev/null 2>&1 && log "lustre rmmod ok" || log "lustre rmmod failed"
/sbin/ifdown eth1:0 && log "eth1:0 down ok" || log "eth1:0 down failed"
/sbin/drbdadm secondary mdt && log "drbd secondary ok" || log "drbd secondary failed"
