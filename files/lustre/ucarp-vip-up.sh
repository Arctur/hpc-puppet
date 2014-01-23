#!/bin/sh
#ideas taken from http://www.gentoo-wiki.info/HOWTO_Setup_2_Node_Active_Passive_Cluster_With_DRBD_UCARP

log()
{
	logger -t carp-vip-up "$*"
}

wait for other side to release drbd
until grep -q "ro:Secondary/[Secondary,Unknown]" /proc/drbd
do
	log "waiting for drbd to become available"
	sleep 5
done

#TODO: adjust eth interface to your needs
/sbin/drbdadm primary mdt && log "drbd primary ok" || log "drbd primary failed"
/sbin/ifup eth1:0 && log "eth1:0 up ok" || log "eth1:0 up failed"
modprobe lnet && log "lnet insert ok" || log "lnet insert failed"
modprobe lustre && log "lustre insert ok" || log "lustre insert failed"
lctl network up >/dev/null 2>&1 && log "lnet up ok" || log "lnet up failed"
mount /lustre && log "lustre mount ok" || log "lustre mount failed"

#if you want to force rr more than QoS
#echo "55%" > /proc/fs/lustre/lov/lustre22-MDT0000-mdtlov/qos_threshold_rr
