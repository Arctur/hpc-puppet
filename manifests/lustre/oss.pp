class hpc-puppet::lustre::oss {

case $productname {
	#TODO: I strongly advise against those servers for Lustre use 
	'ProLiant DL320s G1', 'ProLiant DL320 G5': {
		#but nevertheless you can see how smartarray has to be tweaked to achieve something you can call "useable" performance
		#surely most of these will be totaly different on your hardware, but the goal is to achieve 1MB write without raid rereads
		#assume c0d1 raid5 build from bios tool
		exec { 'setstripesize':
			command => "/usr/sbin/hpacucli ctrl slot=2 ld 2 modify ss=128",
			#only if it is not 128 already
			onlyif => "/usr/sbin/hpacucli ctrl slot=2 ld 2 show | grep 'Strip Size' | grep -qv 128",
			require => Package [ 'hpacucli' ],
		}

		#create aligned partition
		exec { 'creategpt':
			command => "/sbin/parted -s /dev/cciss/c0d1 -a optimal mklabel gpt && /sbin/parted -s /dev/cciss/c0d1 mkpart primary ext4 64 100%",
			#but only if it is not yet there
			unless => "grep -q c0d1p1 /proc/partitions",
			#and array is properly configured
			onlyif => "grep 5860331896 /proc/partitions | grep -q c0d1",
			require => Exec ['setstripesize'],
		}
		
		#mkfs manually by lustre docs at http://wiki.whamcloud.com/display/PUB/Create+and+Mount+a+Lustre+Filesystem
		#use --mkfsoptions="-E stride=32,stripe-width=256 -m 0"

		#configure network

		#first, do the magic
		file { '/etc/sysctl.conf':
			source => 'puppet:///modules/hpc-puppet/lustre/sysctl.conf',
			ensure => present,
			notify => Exec [ 'sysctl' ],
		}
		#for things that cannot be set with sysctl and ifcfg-ethX
		file {'/etc/rc.local': 
			source => 'puppet:///modules/hpc-puppet/lustre/rc.local',
			ensure => present,
		}
		#manually tweak udev rules for onboard nic1 to be eth0
		file { '/etc/sysconfig/network-scripts/ifcfg-eth1':
			content => template ('hpc-puppet/lustre/ifcfg-eth1.erb'),
			ensure => present,
		}
		file { '/etc/sysconfig/network-scripts/ifcfg-eth2':
			content => template ('hpc-puppet/lustre/ifcfg-eth2.erb'),
			ensure => present,
		}
		file { '/etc/modprobe.d/bonding.conf':
			source => 'puppet:///modules/hpc-puppet/lustre/bonding.conf',
			ensure => present,
			notify => Service [ 'network' ],
		}
		$bondaddress=$lastipoctet+200 #0-84 are nodes, 19[89] are MDSes, 200 is MDS floating IP, 200+ are OSSes
		file { '/etc/sysconfig/network-scripts/ifcfg-bond0':
			content => template ('hpc-puppet/lustre/ifcfg-bond0.erb'),
			require => [ File [ '/etc/sysconfig/network-scripts/ifcfg-eth1' ],
					File [ '/etc/sysconfig/network-scripts/ifcfg-eth2' ],
					File [ '/etc/modprobe.d/bonding.conf' ],
					],
			notify => Service [ 'network' ],
		}

		#configure lnet
		file { '/etc/modprobe.d/lnet.conf':
			source => 'puppet:///modules/hpc-puppet/lustre/lnet.conf',
			ensure => present,
			require => File [ '/etc/sysconfig/network-scripts/ifcfg-bond0' ],
		}

		#apply io subsys optimisations
		file { '/root/io_opts.sh':
			source => 'puppet:///modules/hpc-puppet/lustre/dl320s_opts.sh',
			ensure => present,
			mode => 0755,
		}
		exec { 'apply_io_opts':
			command => '/root/io_opts.sh',
			require => File [ '/root/io_opts.sh' ],
			#no worries if this runs every time
		}

	}

	default: {}

}

}
