class hpc-puppet::head::torque {

	package { 'torque-server':
		ensure => latest,
		}
	package { 'torque-client':
		ensure => latest,
		}
	file { '/var/lib/torque/server_priv/nodes':
		source => 'puppet:///modules/hpc-puppet/pbs_nodes',
		mode => 0644,
		ensure => present,
		replace => "no", #so it is only put there for the first time
		notify => Service [ 'pbs_server' ],
	}

	exec { 'set-torque-name':
		command => "hostname -f > /var/lib/torque/server_name",
		unless => "grep -q `hostname -f` /var/lib/torque/server_name",
	}

	service { 'pbs_server':
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		require => [ Package ['torque-server'],
				File [ '/var/lib/torque/server_priv/nodes' ],
				Service [ 'munge' ],
				Exec ['set-torque-name'],
			]
	}
	#configure server
	exec { 'configure-torque-server':
		command => "qmgr -c 'set server auto_node_np = True' && \
				qmgr -c 'set server scheduling = True' && \
				qmgr -c 'set server default_queue = default' && \
				qmgr -c 'set server mail_from = pbs@hpc.lan' && \
				qmgr -c 'set server resources_available.ncpus = 1008' && \
				qmgr -c 'set server resources_available.nodect = 84' && \
				qmgr -c 'set server resources_available.nodes = 84' && \
				qmgr -c 'set server resources_max.ncpus = 1008' && \
				qmgr -c 'set server resources_max.nodes = 84' && \
				qmgr -c 'set server scheduler_iteration = 60' && \
				qmgr -c 'set server node_check_rate = 150' && \
				qmgr -c 'set server tcp_timeout = 6'
			",
		require => Service [ 'pbs_server' ],
		unless => "qmgr -c 'p s' | grep -q \"server default_queue = default\"",
	}
	
	# http://www.clusterresources.com/torquedocs21/4.1queueconfig.shtml

	#create default queue
	exec { 'create-default-queue':
		command => "qmgr -c 'create queue default' && \
				qmgr -c 'set queue default queue_type = Route' && \
				qmgr -c 'set queue default route_destinations += large' && \
				qmgr -c 'set queue default route_destinations += medium' && \
				qmgr -c 'set queue default route_destinations += small' && \
				qmgr -c 'set queue default enabled = True' && \
				qmgr -c 'set queue default started = True'
			",
		unless => "qmgr -c 'p s' | grep -q \"queue default enabled\"",
		require => Service [ 'pbs_server' ],
	}

	#create queue for grid jobs
	exec { 'create-small-queue':
		command => "qmgr -c 'create queue grid' && \
				qmgr -c 'set queue grid queue_type = Execution' && \
				qmgr -c 'set queue grid resources_min.ncpus = 1' && \
				qmgr -c 'set queue grid resources_min.nodect = 1' && \
				qmgr -c 'set queue grid resources_default.ncpus = 1' && \
				qmgr -c 'set queue grid resources_default.nodect = 1' && \
				qmgr -c 'set queue grid enabled = True' && \
				qmgr -c 'set queue grid started = True'
			",
		require => Exec ['create-default-queue'],
		unless => "qmgr -c 'p s' | grep -q \"queue grid enabled\"",
	}
	#create queue for small jobs
	exec { 'create-small-queue':
		command => "qmgr -c 'create queue small' && \
				qmgr -c 'set queue small queue_type = Execution' && \
				qmgr -c 'set queue small resources_min.ncpus = 1' && \
				qmgr -c 'set queue small resources_min.nodect = 1' && \
				qmgr -c 'set queue small resources_default.ncpus = 1' && \
				qmgr -c 'set queue small resources_default.nodect = 1' && \
				qmgr -c 'set queue small enabled = True' && \
				qmgr -c 'set queue small started = True'
			",
		require => Exec ['create-default-queue'],
		unless => "qmgr -c 'p s' | grep -q \"queue small enabled\"",
	}
	#create queue for medium jobs
	exec { 'create-medium-queue':
		command => "qmgr -c 'create queue medium' && \
				qmgr -c 'set queue medium queue_type = Execution' && \
				qmgr -c 'set queue medium resources_min.ncpus = 253' && \
				qmgr -c 'set queue medium resources_min.nodect = 22' && \
				qmgr -c 'set queue medium enabled = True' && \
				qmgr -c 'set queue medium started = True'
			",
		require => Exec ['create-default-queue'],
		unless => "qmgr -c 'p s' | grep -q \"queue medium enabled\"",
	}
	#create queue for large jobs
	exec { 'create-large-queue':
		command => "qmgr -c 'create queue large' && \
				qmgr -c 'set queue large queue_type = Execution' && \
				qmgr -c 'set queue large resources_min.ncpus = 505' && \
				qmgr -c 'set queue large resources_min.nodect = 43' && \
				qmgr -c 'set queue large enabled = True' && \
				qmgr -c 'set queue large started = True'
			",
		require => Exec ['create-default-queue'],
		unless => "qmgr -c 'p s' | grep -q \"queue large enabled\"",
	}

        #provide emi repos
        package { 'yum-plugin-protectbase':
                ensure => present,
        }
        package { 'yum-plugin-priorities':
                ensure => present,
        }
        exec { 'install-emi-repo':
                command => "rpm -ivh http://emisoft.web.cern.ch/emisoft/dist/EMI/3/sl6/x86_64/base/emi-release-3.0.0-2.el6.noarch.rpm",
                unless => "test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-emi",
                require => [ Package [ 'yum-plugin-protectbase' ], Package [ 'yum-plugin-priorities' ], ],
        }
	
	$mauipkg = [ 'maui-server', 'maui-client' ]
	package { $mauipkg:
		ensure => latest,
		require => Exec [ 'install-emi-repo' ],
	}
	file { '/var/spool/maui/maui.cfg':
		ensure => present,
		content => template ('hpc-puppet/maui.cfg.erb'),
		require => Package [ 'maui-server' ],
		notify => Service [ 'maui' ],
	}
	service { 'maui':
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		require =>  [ Package ['maui-server'], Package [ 'maui-client' ], ]
	}
}
