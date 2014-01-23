class hpc-puppet::swbuilder {
	include 'hpc-puppet::common::distro-devtools'
	include 'hpc-puppet::swbuilder::eb'
	include 'hpc-puppet::common::icr_interactive'
	include 'hpc-puppet::common::icr_libs'
	#TODO: manually configure network on this node
	#TODO: also needs yum groupinstall "Desktop Platform Development"

	user { 'swadmin':
                ensure => present,
                uid => 480,
                shell => '/bin/bash',
        }

	mount { '/opt':
                device  => "nfshost:/opt",
                fstype  => "nfs4",
                ensure  => "mounted",
                options => "defaults",
                atboot  => "true",
                require => [ Package ['nfs-utils'], File [ '/etc/hosts' ], ],
        }

	mount { '/usr/local':
                device  => "nfshost:/usrlocal",
                fstype  => "nfs4",
                ensure  => "mounted",
                options => "defaults",
                atboot  => "true",
                require => [ Package ['nfs-utils'], File [ '/etc/hosts' ], ],
        }

	$head_sw_dirs = [ '/usr/local/modules', '/usr/local/software', ]
        file { $head_sw_dirs:
                ensure => directory,
                owner => 'swadmin',
        }

	#TODO: add administrators' keys
	ssh_authorized_key { "admin1":
                user => 'swadmin',
                type => 'ssh-rsa',
                name => 'admin1',
                key => '...',
                ensure => present,
        }
	ssh_authorized_key { "admin2":
                user => 'swadmin',
                type => 'ssh-dss',
                name => 'admin2',
                key => '...',
                ensure => present,
        }

	#some devel packages we need:
	$develpkglist = [ 'libjpeg-turbo-devel', 'intel-shmem-devel', 'torque-devel', 'libibverbs-devel',
			'libibmad-devel', 'kernel-ib-devel', 'libibverbs-devel-static', 'librdmacm-devel',
			'infinipath-devel', 'libmlx4-devel', 'torque-drmaa-devel', 'libibumad-devel', 'libibcm-devel',
			'opensm-devel', 'numactl-devel', ]
	package { $develpkglist:
		ensure => present,
	}
}
