class hpc-puppet::node::nfs {
	#TODO: take care of nfshost hostname
	mount { '/home':
		device  => "nfshost:/home",
		fstype  => "nfs4",
		ensure  => "mounted",
		options => "defaults,intr",
		atboot  => "true",
		require => [ Package ['nfs-utils'], File [ '/etc/hosts' ], ],
	}
	mount { '/opt':
		device  => "nfshost:/opt",
		fstype  => "nfs4",
		ensure  => "mounted",
		options => "defaults,intr",
		atboot  => "true",
		require => [ Package ['nfs-utils'], File [ '/etc/hosts' ], ],
	}
	mount { '/usr/local':
		device  => "nfshost:/usrlocal",
		fstype  => "nfs4",
		ensure  => "mounted",
		options => "defaults,intr",
		atboot  => "true",
		require => [ Package ['nfs-utils'], File [ '/etc/hosts' ], ],
	}
}
