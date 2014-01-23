class hpc-puppet::node::ssh {
        #TODO: provide root public key
        ssh_authorized_key { "root":
                user => 'root',
                type => 'ssh-rsa',
                name => 'hpc-root',
                key => '...',
                ensure => present,
        }

	#our policy is to run sshd on mngmt if reachable only from certain hosts
	#so for cluster needs we run anoter "internal" sshd on $hpclan
	#we have to bind this sshd to IPs in /etc/hosts 
	
	file { '/etc/sysconfig/sshd-int':
		source => 'puppet:///modules/hpc-puppet/sysconfig_sshd',
		ensure => present,
	}
	file { '/etc/init.d/sshd-int':
		source => 'puppet:///modules/hpc-puppet/sshd-init',
		ensure => present,
	}
	#TODO: fix ip to bind to in this template
	file { '/etc/ssh/sshd-int_config':
		content => template ('hpc-puppet/sshd_config.erb'),
		ensure  => present,
	}
	service { 'sshd-int':
		enable => true,
		ensure => running,
		require => [ File [ '/etc/sysconfig/sshd-int' ], File [ '/etc/init.d/sshd-int' ], File [ '/etc/ssh/sshd-int_config' ], ],
	}
}
