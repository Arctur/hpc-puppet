class hpc-puppet::mon::gmetad {
	#monitoring node is collecting metrics
	package { 'ganglia-gmetad':
		ensure => latest,
	}
	file { '/etc/ganglia/gmetad.conf':
		source => 'puppet:///modules/hpc-puppet/gmetad.conf',
		ensure => present,
		notify => Service [ 'gmetad' ],
	}
	service { 'gmetad':
		ensure => running,
		enable => true,
		require => [ Package [ 'ganglia-gmetad' ], File [ '/etc/ganglia/gmetad.conf' ], ],
	}
}
