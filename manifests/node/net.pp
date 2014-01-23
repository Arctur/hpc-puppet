class hpc-puppet::node::net {
	#TODO: review and adjust network settings

	#eth0 is up since install but on temporary IP
	#we set proper IPs here
	file { "/etc/sysconfig/network-scripts/ifcfg-$mngmtif":
		content => template ('hpc-puppet/node_mngmtif.erb'),
		ensure  => present,
		notify  => Service [ 'network' ],
	}

	#eth for lustre
	case $hostname {
		'fatnode0': {
			file { '/etc/sysconfig/network-scripts/ifcfg-eth4':
				content => template ('hpc-puppet/fatnode_eth4.erb'),
				ensure  => present,
				notify  => Service [ 'network' ],
			}
		}
		default: {
			file { "/etc/sysconfig/network-scripts/ifcfg-$lustreif":
				content => template ('hpc-puppet/node_lustreif.erb'),
				ensure  => present,
				notify  => Service [ 'network' ],
			}
		}
	}

	#eth1 
	file { "/etc/sysconfig/network-scripts/ifcfg-$hpclanif":
		content => template ('hpc-puppet/node_hpclanif.erb'),
		ensure  => present,
		notify  => Service [ 'network' ],
	}

	#route multicast over internal lan for ganglia to work
	#TODO: this assumes that node gmetad and ganglia web is also sits on hpc lan
	file { "/etc/sysconfig/network-scripts/route-$hpclanif":
		content => template ('hpc-puppet/route-multicast.erb'),
		ensure => present,
		notify => Service [ 'network' ],
	}
}

