#!/bin/bash

#only if lustre is up
if [ -f /opt/scripts/lustre_up ]
then
	mkdir -p /lustre/$USER
	chmod 700 /lustre/$USER
	export SCRATCH="/lustre/$USER"
fi
