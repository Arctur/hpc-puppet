class hpc-puppet::lustre::client ($lkernel="2.6.32_358", $lver="2.1.6", $lif="eth0.16") {

	$pkglist = [ "lustre-client", "lustre-client-modules", ]

	package { $pkglist:
		ensure => "$lver-$kernelreleaseunderscore",
		require => File [ '/etc/yum.repos.d/lustre.repo' ], 
	}
	
	file { '/etc/modprobe.d/lnet.conf':
		content => template ('hpc-puppet/lustre/lnet.conf.erb'),
		ensure => "present",
	}
	
	file { "/lustre":
		ensure => "directory",
	}

	#TODO: set this to your hosts and addresses
	mount { "/lustre":
		device  => "172.16.0.200@tcp0:/lustre22",
		fstype  => "lustre",
		ensure  => "present",
		options => "defaults,_netdev,noauto",
        	atboot  => "no",
	}

	exec { 'add-lustre-to-rclocal':
		command => "echo '/opt/scripts/mount_lustre.sh' >> /etc/rc.local",
		unless  => "grep -q mount_lustre /etc/rc.local",
	}

	file { '/etc/profile.d/lustre.sh':
		source => 'puppet:///modules/hpc-puppet/profile-lustre.sh',
		ensure => present,
	}
}
