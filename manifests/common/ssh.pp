class hpc-puppet::common::ssh {
	#TODO: provide root ssh private key
	file { '/root/.ssh/id_rsa':
		source => 'puppet:///modules/hpc-puppet/id_rsa',
                mode => 0400,
		ensure => present,
	}

	#TODO: provide root ssh public key, matching private key above
	ssh_authorized_key { "headnode":
		user => 'root',
		type => 'ssh-rsa',
		name => 'hpc-root',
		key => '...',
		ensure => present,
	}

	#generate users' keys
	file { '/etc/profile.d/ssh.sh':
		source => 'puppet:///modules/hpc-puppet/profile-ssh.sh',
		mode => 0755,
		ensure => present,
	}
}

