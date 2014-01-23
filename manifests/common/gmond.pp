class hpc-puppet::common::gmond {
	#install ganglia metric gathering
	package { 'ganglia-gmond':
		ensure => latest,
	}
	file { '/etc/ganglia/gmond.conf':
		content => template('hpc-puppet/gmond.conf'),
		ensure => present,
		notify => Service [ 'gmond' ],
	}
	service { 'gmond':
		ensure => running,
		enable => true,
		require => [ Package [ 'ganglia-gmond' ], File [ '/etc/ganglia/gmond.conf' ], ],
	}
}
