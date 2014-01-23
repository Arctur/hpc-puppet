#!/bin/bash

echo 4096 > /sys/block/cciss\!c0d1/queue/max_sectors_kb
echo deadline > /sys/block/cciss\!c0d1/queue/scheduler
echo 8192 > /sys/block/cciss\!c0d1/queue/nr_requests
blockdev --setra 32768 /dev/cciss/c0d1

echo 1> /proc/scsi/sg/allow_dio
