class hpc-puppet::nfshost {
	#TODO: manually configure filesystems on this node
	#TODO: manually configure network on this node
	#TODO: manualy configure exports file
	#export /opt and /usr/local rw only to swbuilder

	#nfs config
	file { '/etc/sysconfig/nfs':
		source => 'puppet:///modules/hpc-puppet/sysconfig_nfs',
	}
	service { 'rpcbind':
		enable => true,
		ensure => running,
		require => File [ '/etc/sysconfig/nfs' ],
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

