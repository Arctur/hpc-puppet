class hpc-puppet::grid::worker {
	#take care for /cache
	case $hostname {
		'fatnode0': {
			#manually edit /etc/exports
			file { '/etc/sysconfig/nfs':
		                source => 'puppet:///modules/hpc-puppet/sysconfig_nfs',
		        }
			service { 'nfs':
		                enable => true,
		                ensure => running,
		        }
			file { '/etc/idmapd.conf':
         		       source => 'puppet:///modules/hpc-puppet/idmapd.conf',
		        }
		        service { 'rpcidmapd':
		                enable => true,
		                ensure => running,
		                require => File [ '/etc/idmapd.conf' ],
		        }
		}
		default: {
			if ($infiniband != "" ) {
			file { '/cache':
				ensure => directory,
			}
			mount { '/cache':
	         	       device  => "ib-fatnode0:/cache",
		               fstype  => "nfs4",
		               ensure  => "mounted",
		               options => "defaults,intr",
		               atboot  => "true",
		               require => [ File ['/cache'], File [ '/etc/hosts' ], File [ '/etc/sysconfig/network-scripts/ifcfg-ib0' ], ],
		        }
			}
		}
	}

	$cvmfspkgs = [ 'cvmfs', 'cvmfs-init-scripts', 'cvmfs-auto-setup' ]
	package { $cvmfspkgs:
		ensure => latest,
	}
	file { '/etc/cvmfs/default.local':
		source => 'puppet:///modules/hpc-puppet/cvmfs.default.local',
	}
	service { 'autofs':
		enable  => true,
		ensure  => running,
		require => [ File [ '/etc/cvmfs/default.local' ], Package [ 'cvmfs' ], ],
	}
	exec { 'enable-cvmfs':
		command => 'echo "/cvmfs /etc/auto.cvmfs" >> /etc/auto.master',
		unless  => 'grep -q cvmfs /etc/auto.master',
		notify  => Service [ 'autofs' ],
	}
			
}
