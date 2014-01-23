class hpc-puppet::node::torque ($interactive=no) {

	package { 'torque-mom':
		ensure => latest,
		}

	file { '/var/lib/torque/mom_priv/config':
		source  => 'puppet:///modules/hpc-puppet/mom_config',
		ensure  => present,
		require => Package [ 'torque-mom' ],
		notify  => Service ['pbs_mom'],
		}
	file { '/sbin/health_check.sh':
		source => 'puppet:///modules/hpc-puppet/health_check.sh',
		ensure => present,
		mode => 0755,
	}
	file { '/etc/sysconfig/pbs_mom':
		source => 'puppet:///modules/hpc-puppet/sysconfig_pbsmom',
		ensure => present,
		mode => 0644,
		notify => Service ['pbs_mom'],
	}
	#TODO: set this to your pbs hostname
        exec { 'set-torque-name':
                command => "echo pbs.hpc.lan > /var/lib/torque/server_name",
                unless => "grep -q pbs.hpc.lan /var/lib/torque/server_name",
        }

	service { 'pbs_mom':
		ensure     => $interactive ? { no => 'running', yes => 'stopped' },
		enable     => true,
		hasstatus  => true,
		hasrestart => true,
		require => [ File [ '/var/lib/torque/mom_priv/config' ],
				File [ '/sbin/health_check.sh' ],
				Service [ 'munge' ],
				Exec [ 'set-torque-name' ],
			   ],
	}

	file { '/etc/security/limits.d/10_mpi.conf':
                source => 'puppet:///modules/hpc-puppet/limits_mpi.conf',
                ensure => present,
        }
}
