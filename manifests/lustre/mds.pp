class hpc-puppet::lustre::mds {

case $productname {
	#TODO: I hope you run those on better hw; change accordingly
	'ProLiant DL360 G5': {
		#TODO: configure network: idea here is to have one floating ip, managed with carp
		file { '/etc/sysconfig/network-scripts/ifcfg-eth1':
			content => template ('hpc-puppet/lustre/ifcfg-eth1-mds.erb'),
			ensure => present,
			notify => Service [ 'network' ],
		}
		file { '/etc/sysconfig/network-scripts/ifcfg-eth1:0':
			source => 'puppet:///modules/hpc-puppet/lustre/ifcfg-eth1_0',
			ensure => present,
			require => File [ '/etc/sysconfig/network-scripts/ifcfg-eth1' ],
		}
		#TODO: and one eth that directly connects to the other mds
		file { '/etc/sysconfig/network-scripts/ifcfg-eth2':
			content => template ('hpc-puppet/lustre/ifcfg-eth2-mds.erb'),
			ensure => present,
			notify => Service [ 'network' ],
		}

		#configure drbd
		#TODO: these magic numbers directly relate to the disks we use and partitions we create
		exec { 'lvcreate':
			command => 'lvcreate -l 4054 -n mdt vg0',
			onlyif => 'vgdisplay | grep "Free  PE" | grep -q 4178',
		}
		package { 'drbd84-utils':
			ensure => installed,
		}
		#TODO: recompile drbd module for your kernel
		file { '/lib/modules/2.6.32-220.4.2.el6_lustre.x86_64/extra/drbd.ko':
			source => 'puppet:///modules/hpc-puppet/lustre/drbd.ko',
			ensure => present,
			require => Package [ 'drbd84-utils' ],
			notify => Exec [ 'depmod' ],
		}
		file { '/etc/drbd.conf':
			source => 'puppet:///modules/hpc-puppet/lustre/drbd.conf',
			ensure => present,
			require => File [ '/lib/modules/2.6.32-220.4.2.el6_lustre.x86_64/extra/drbd.ko' ],
			notify => Service [ 'drbd' ],
		}

		#TODO: first init drbd0 manually: drbdadm create-md mdt, drbdadm primary --force mdt

		service { 'drbd':
			ensure => running,
			enable => true,
			require => [ Package [ 'drbd84-utils' ],
					File [ '/etc/drbd.conf' ],
				],
		}

		#configure ucarp
		package { 'ucarp':
			ensure => latest,
			require => [ File [ '/etc/sysconfig/network-scripts/ifcfg-eth1:0' ],
					File [ '/etc/sysconfig/network-scripts/ifcfg-eth2' ],
					File [ '/etc/drbd.conf' ],
				],
		}
		file { '/etc/ucarp/vip-001.conf':
			content => template ('hpc-puppet/lustre/ucarp-vip-001.conf'),
			require => Package ['ucarp'],
			notify => Service [ 'ucarp' ],
		}
		file { '/etc/ucarp/vip-up.sh':
			source => 'puppet:///modules/hpc-puppet/lustre/ucarp-vip-up.sh',
			mode => 0755,		
		}
		file { '/etc/ucarp/vip-down.sh':
			source => 'puppet:///modules/hpc-puppet/lustre/ucarp-vip-down.sh',
			mode => 0755,
		}
		service { 'ucarp':
			ensure => running,
			enable => true,
			require => [ Package [ 'ucarp' ],
					File [ '/etc/ucarp/vip-001.conf' ],
					File [ '/etc/ucarp/vip-up.sh' ],
					File [ '/etc/ucarp/vip-down.sh' ],
				],
		}

		#configure lnet
		file { '/etc/modprobe.d/lnet.conf':
			source => 'puppet:///modules/hpc-puppet/lustre/lnet-mds.conf',
			ensure => present,
			require => File [ '/etc/sysconfig/network-scripts/ifcfg-eth1:0' ],
		}

		#TODO: manually mkdir /lustre and add entry to fstab
		#something like "/dev/drbd0 /lustre lustre defaults,noauto 0 0" is sufficient

	}

	default: {}

}

}
