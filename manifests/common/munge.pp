class hpc-puppet::common::munge {
#munge service to protect torque communication between nodes
#see http://code.google.com/p/munge/	
	package { 'munge':
                ensure => latest,
                }

	#TODO: generate a new one
	file { '/etc/munge/munge.key':
                source => 'puppet:///modules/hpc-puppet/munge.key',
		mode => 0400,
		ensure => present,
		owner => 'munge',
		group => 'munge',
                require => Package['munge'],
        }

        service { 'munge':
                ensure => running,
                enable => true,
                require => File['/etc/munge/munge.key'],
        }
}
