class hpc-puppet::lustre::server {

	package { 'kernel':
		#TODO: pick the desired kernel from whamcloud
		ensure => '2.6.32-220.4.2.el6_lustre',
		require => File [ '/etc/yum.repos.d/lustre.repo' ],
		notify => Exec ['reboot'],
	}

	#TODO: install latest network drivers to prevent certain problems
	#if you're poor like us and run lustre over eth, build latest driver pkgs and put them into your repo
	$netpkglist = [ 'e1000e', 'tg3', 'netxtreme2' ]
	package { $netpkglist:
		ensure => 'latest',
		require => Package [ 'kernel' ],
	}
	
	#also as above, get matching version from whamcloud
	package { 'e2fsprogs':
		ensure => '1.42.3.wc3-7.el6',
		require => File [ '/etc/yum.repos.d/lustre.repo' ],
	}

	$pkglist = [ "lustre", "lustre-ldiskfs", "lustre-modules", "perf" ]

	package { $pkglist:
		ensure => installed,
		require => [ Package [ 'kernel' ],
				Package [ 'e2fsprogs' ],
				],
	}
}
