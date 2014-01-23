class hpc-puppet::common::icr_libs {
	exec { 'yum-update':
		command => 'yum -y --exclude=kernel* update',
		refreshonly => true,
	}

	#comply with Intel Cluster Ready v1.3 sw requirements
	#http://software.intel.com/sites/default/files/Intel_Cluster_Ready_Specification_1.3_Final.pdf
	#6.2.5 libs (OS 32bit & 64bit libs)

	$icrlibpkglist = [ 'libacl.x86_64', 'libacl.i686',
			'libattr.x86_64', 'libattr.i686',
			'bzip2-libs.x86_64', 'bzip2-libs.i686',
			'libcap.x86_64', 'libcap.i686',
			'ncurses-libs.x86_64', 'ncurses-libs.i686',
			'pam.x86_64', 'pam.i686',
			'zlib.x86_64', 'zlib.i686', ]
	package { $icrlibpkglist:
		ensure => latest,
		require => Exec [ 'yum-update' ],
	}

	#6.2.6 compiler runtimes
	#a GNU gcc >= 4.1
	$icrgnupkglist = [ 'libgcc.x86_64', 'libgcc.i686' ]
	package { $icrgnupkglist:
		ensure => latest,
		require => Exec [ 'yum-update' ],
	}

	#these live in /opt nfs share
	#b icc >= 2013.1
	#c ifort >= 2013.1
	#d iMKL >= 11.01
	#e iMPI >= 4.1
	#f iTBB >= 4.1.1

	#6.2.8 runtime libs (leave out libjpeg-turbo.i686 until 1.3 is recompiled for i686)
	$icrruntimepkglist = [ 'glibc.x86_64', 'glibc.i686',
			'openssl.x86_64', 'openssl.i686',
			'openssl098e.x86_64', 'openssl098e.i686',
			'libjpeg-turbo.x86_64', 
			'nss-pam-ldapd.x86_64', 'nss-pam-ldapd.i686',
			'numactl.x86_64', 'numactl.i686',
			'libstdc++.x86_64', 'libstdc++.i686',
			'compat-libstdc++-33.x86_64', 'compat-libstdc++-33.i686',
			'libuuid.x86_64', 'libuuid.i686', ]
	package { $icrruntimepkglist:
		ensure => latest,
		require => Exec [ 'yum-update' ],
	}

	#6.2.9 JRE
	package { 'java-1.6.0-openjdk.x86_64':
		ensure => latest,
	}

	#6.2.10 64bit X11
	$icrx11pkglist = [ 'libdrm', 'fontconfig', 'freetype', 'xorg-x11-drv-intel',
			'mesa-libGL', 'mesa-libGLU', 'libSM', 'libX11', 'libXres', 
			'libXau', 'libXcomposite', 'libXcursor', 'libXdamage', 
			'libXdmcp', 'libXext', 'libXfixes', 'libXfont', 'libXft', 
			'libXi', 'libXinerama', 'libXmu', 'libXp', 'libXrandr', 
			'libXrender', 'libXScrnSaver', 'libXt', 'libXtst', 'libXv', 
			'libXvMC', 'libXxf86dga', 'libXxf86misc', 'libXxf86vm', ]
	package { $icrx11pkglist:
		ensure => latest,
	}

	#6.3 cli & tools
	$icrclipkglist = [ 'bash', 'python', 'tcl', 'perl', ]
	package { $icrclipkglist:
		ensure => latest,
	}
}
