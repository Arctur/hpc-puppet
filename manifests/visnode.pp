class hpc-puppet::visnode {
	exec { 'install-desktop':
		command => 'yum -d 0 -e 0 -y groupinstall Desktop',
		unless  => 'rpm -q redhat-menus',
	}
	exec { 'install-desktop-platform':
		command => 'yum -d 0 -e 0 -y groupinstall "Desktop Platform"',
		unless  => 'rpm -q redhat-lsb-graphics',
	}
	exec { 'install-kde-desktop':
		command => 'yum -d 0 -e 0 -y groupinstall "KDE Desktop"',
		unless  => 'rpm -q kdebase-libs',
	}
	exec { 'install-x':
		command => 'yum -d 0 -e 0 -y groupinstall "X Window System"',
		unless  => 'rpm -q xorg-x11-xinit',
	}

	exec { 'remove-nm':
		command => 'yum -d 0 -e 0 -y remove NetworkManager-gnome NetworkManager',
		onlyif  => 'rpm -q NetworkManager',
		require => Exec [ 'install-desktop' ],
	}

	exec { 'install-x-fonts':
		command => 'yum -y install xorg-x11-fonts-*',
		unless => 'rpm -q xorg-x11-fonts-75dpi',
	}

	#some user requested stuf
	$visuserpkgs = [ 'gedit', 'gnuplot44', ]
	package { $visuserpkgs:
		ensure => latest,
	}
}
