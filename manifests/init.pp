# these are common settings that all nodes in the cluster get

class hpc-puppet {
	include 'hpc-puppet::common'

	#no time to be bothered by these
	augeas { 'disable-selinux':
                        context => '/etc/sysconfig/selinux',
                        changes => 'set /files/etc/sysconfig/selinux/SELINUX disabled',
			notify => Exec ['reboot'],
               }

	#we don't want packages to be auto updated without us knowing
	package { 'yum-plugin-auto-update':
		ensure => absent,
	}

	#present uniform view of hosts TODO: fill this in yourself
	file { '/etc/hosts':
        	source => 'puppet:///modules/hpc-puppet/hosts',
	        ensure => present,
	}

	#take care of env modules
	package { 'environment-modules':
		ensure => latest,
	}
	file { '/usr/share/Modules/init/.modulespath':
		source => 'puppet:///modules/hpc-puppet/modulespath',
		ensure => present,
		require => Package [ 'environment-modules' ],
	}

	#we have nfs mounts
	package { 'nfs-utils':
                ensure => latest,
        }

        #allow ssh to work without questions
        exec { 'edit-ssh-config':
                command => "echo StrictHostKeyChecking no >> /etc/ssh/ssh_config",
                unless => "grep -q ^StrictHostKeyChecking /etc/ssh/ssh_config",
        }

        #provide some parallel ssh tool
        package { 'pdsh-mod-torque':
                ensure => latest,
        }
	package { 'pdsh-mod-genders' :
		ensure => latest,
	}

	#and provide some genders description
	file { '/etc/genders':
		source => 'puppet:///modules/hpc-puppet/genders',
		ensure => present,
	}

	#TODO: provide required packages not in public repos. These include:
	#http://downloads.whamcloud.com/public/lustre/ for desired lustre versions (watch minor kernel revisions or build client pkgs yourself)
	#http://emisoft.web.cern.ch/emisoft/index.html maui client and server from EMI2 third-party
	#Qlogic and Mellanox OFED stacks (just dump rpms from their tarballs here)
	file { '/etc/yum.repos.d/hpc.repo':
                source => 'puppet:///modules/hpc-puppet/hpc.repo',
                ensure => present,
        }
}

