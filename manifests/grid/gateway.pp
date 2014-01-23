class hpc-puppet::grid::gateway {
	#TODO: configure network manually (this node needs public IP)

	#In our case this is the primary opensm node
	class { 'hpc-puppet::common::ibstack': mngmt => true }
	exec { 'set-opensm-primary':
		command => 'sed -i "s/\#PRIORITY=15/PRIORITY=15/" /etc/sysconfig/opensm',
		onlyif  => 'grep -q "#PRIO" /etc/sysconfig/opensm',
		require => Package [ 'opensm' ],
		notify  => Service [ 'opensm' ],
	}

	#needs to be pbs client, but not compute node
	class { 'hpc-puppet::node::torque': interactive => "yes" }
	include 'hpc-puppet::common::munge'
	include 'hpc-puppet::node::torqueclient'

	#TODO: CERN stuf needs /cache; in our case we mount it from our fatnode
	#via nfs-rdma over IB, but you can do this differently or omit entirely
	file { '/cache':
		ensure => directory,
	}
        mount { '/cache':
		device  => "ib-fatnode0:/cache",
		fstype  => "nfs4",
		ensure  => "mounted",
		options => "defaults,intr",
		atboot  => "true",
		require => [ Package ['nfs-utils'], File [ '/etc/hosts' ], File [ '/cache' ], Package [ 'kernel-ib' ], ],
	}

	file {'/etc/yum.repos.d/EGI-trustanchors.repo':
		ensure => present,
		source => 'puppet:///modules/hpc-puppet/grid/EGI-trustanchors.repo',
	}

	$gridpkgs = [ 'nordugrid-arc', 'nordugrid-arc-arex', 'nordugrid-arc-aris', 'nordugrid-arc-ca-utils', 'nordugrid-arc-gridftpd',
			'nordugrid-arc-gridmap-utils', 'nordugrid-arc-hed', 'nordugrid-arc-plugins-globus', 'nordugrid-arc-plugins-needed',
			'nordugrid-arc-ldap-infosys', ]
	package { $gridpkgs:
		ensure => installed,
		require => [ File ['/etc/arc.conf'],  ],
	}
	package {'ca-policy-egi-core':
		ensure => installed,
		require => File ['/etc/yum.repos.d/EGI-trustanchors.repo'],
	}

	#http://www.nikhef.nl/grid/gridwiki/index.php/FetchCRL3
	package {'fetch-crl':
		ensure => latest,
	}
	#TODO: you need to get these from your NGI people
	file {'/etc/grid-security/hostkey.pem':
		owner   => 'root',
		group   => 'root',
		ensure  => present,
		source  => 'puppet:///modules/hpc-puppet/grid/key.pem',
		mode    => 0400,
		require => Package [ 'nordugrid-arc' ],
	}
	file {'/etc/grid-security/hostcert.pem':
		owner => 'root',
		group => 'root',
		ensure => present,
		source => 'puppet:///modules/hpc-puppet/grid/crt.pem',
		require => Package [ 'nordugrid-arc' ],
	}
	file {'/etc/arc.conf':
		ensure => present,
		source => 'puppet:///modules/hpc-puppet/grid/arc.conf',
	}
	
	service {'gridftpd':
		ensure => running,
		enable => true,
		require => Package['ca-policy-egi-core'],
		hasstatus => true,
		hasrestart => true,
		before => [ Service ['nordugrid-arc-slapd'],
				Service ['nordugrid-arc-bdii'],
				Service ['nordugrid-arc-inforeg'],
				Service ['a-rex'], ],
		subscribe => File ['/etc/arc.conf'],
	}
	service {'nordugrid-arc-slapd':
		ensure => running,
		enable => true,
		require => Package ['nordugrid-arc-ldap-infosys'],
		hasstatus => true,
		subscribe => File ['/etc/arc.conf'],
		before => [ Service ['nordugrid-arc-bdii'],
				Service ['nordugrid-arc-inforeg'],
				Service ['a-rex'], ],
	}
	service {'nordugrid-arc-bdii':
		ensure => running,
		enable => true,
		require => Package ['nordugrid-arc'],
		hasstatus => true,
		subscribe => File ['/etc/arc.conf'],
		before => [ Service ['nordugrid-arc-inforeg'],
				Service ['a-rex'], ],
	}
	service {'nordugrid-arc-inforeg':
		ensure => running,
		enable => true,
		require => Package ['nordugrid-arc'],
		hasstatus => true,
		subscribe => File ['/etc/arc.conf'],
		before => Service ['a-rex'],
	}
	service {'a-rex':
		ensure => running,
		enable => true,
		require => Package['nordugrid-arc-arex'],
		hasstatus => true,
		hasrestart => true,
		subscribe => File ['/etc/arc.conf'],
	}
}

