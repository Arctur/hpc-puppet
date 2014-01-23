class hpc-puppet::swbuilder::eb {
	#prep & install easybuild
	#http://hpcugent.github.io/easybuild/
	#http://fotis.web.cern.ch/fotis/HPCBIOS_cheatsheet.pdf
	package { 'python-pip':
		ensure => latest,
	}
	package { 'GitPython':
		ensure => latest,
	}
	package { 'graphviz-python':
		ensure => latest,
	}
	exec { 'install-pygraph':
		command => 'pip install python-graph-dot',
		unless => 'test -d /usr/lib/python2.6/site-packages/python_graph_dot-1.8.2-py2.6.egg-info',
		require => Package [ 'python-pip' ],
	}
	exec { 'install-eb':
		user => 'swadmin',
		command => 'cd && mkdir buildlogs && wget https://raw.github.com/hpcugent/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py && python bootstrap_eb.py /usr/local && rm bootstrap_eb.py',
		unless => 'test -d /usr/local/software/EasyBuild',
		require => [ Package [ 'GitPython' ],
			File [ '/usr/local/software' ],
			Exec [ 'install-pygraph' ],
			]
	}

	#configure eb env
	file { '/home/swadmin/.easybuild':
		ensure => directory,
		owner => 'swadmin',
	}
	file { '/home/swadmin/.easybuild/config.py':
		source => 'puppet:///modules/hpc-puppet/eb_config.py',
		owner => 'swadmin',
		require => [ User [ 'swadmin' ], File [ '/home/swadmin/.easybuild' ], ]
	}


	#set up links in /opt to conform with ICR (6.2.7)
	file { '/opt/intel':
		ensure => directory,
	}

	$intelproddirs = [ '/opt/intel/cc', '/opt/intel/cce', '/opt/intel/fc', '/opt/intel/fce',
			 '/opt/intel/cmkl', '/opt/intel/impi', '/opt/intel/tbb' ]
	file { $intelproddirs:
		ensure  => directory,
		require => File [ '/opt/intel' ],
	}

	#TODO: bootstrap ictce env for eb manually and adjust versions below
	$compver="2013.5.192"
	$impiver="4.1.1.036"
	$imklver="11.0.5.192"

	file { "/opt/intel/cc/$compver":
		ensure  => link,
		target  => "/usr/local/software/icc/$compver/compiler/lib/ia32",
		require => File [ '/opt/intel/cc' ],
	}
	file { "/opt/intel/cce/$compver":
		ensure  => link,
		target  => "/usr/local/software/icc/$compver/compiler/lib/intel64",
		require => File [ '/opt/intel/cce' ],
	}
	file { "/opt/intel/fc/$compver":
		ensure  => link,
		target  => "/usr/local/software/ifort/$compver/compiler/lib/ia32",
		require => File [ '/opt/intel/fc' ],
	}
	file { "/opt/intel/fce/$compver":
		ensure  => link,
		target  => "/usr/local/software/ifort/$compver/compiler/lib/intel64",
		require => File [ '/opt/intel/fce' ],
	}
	file { "/opt/intel/cmkl/$imklver":
		ensure  => link,
		target  => "/usr/local/software/imkl/$imklver/compiler/lib/intel64",
		require => File [ '/opt/intel/cmkl' ],
	}
	file { "/opt/intel/impi/$impiver":
		ensure  => link,
		target  => "/usr/local/software/impi/$impiver/lib64",
		require => File [ '/opt/intel/impi' ],
	}
}
