class hpc-puppet::visnode::tools {
	package { 'libjpeg-turbo-1.2.1-1.el6.i686':
		ensure => absent,
	}
	package { 'VirtualGL':
		ensure  => latest,
		require => Package [ 'libjpeg-turbo-1.2.1-1.el6.i686' ],
	}
	package { 'turbovnc':
		ensure => latest,
		require => Package [ 'libjpeg-turbo-1.2.1-1.el6.i686' ],
	}
	#rpm package takes care of init script tweaks, do the config files here
	file { '/etc/turbovncserver-auth.conf':
		source  => 'puppet:///modules/hpc-puppet/turbovncserver-auth.conf',
		ensure  => present,
		require => Package [ 'turbovnc' ],
	}
	file { '/etc/turbovncserver.conf':
		source  => 'puppet:///modules/hpc-puppet/turbovncserver.conf',
		ensure  => present,
		require => Package [ 'turbovnc' ],
	}

	exec { 'add-vis-to-rclocal':
		command => "echo '( sleep 30; DISPLAY=:0 xhost +local: ) &' >> /etc/rc.local",
		unless  => "grep -q xhost /etc/rc.local",
	}
	file { '/etc/X11/xdm/Xservers':
		source  => 'puppet:///modules/hpc-puppet/Xservers',
		ensure  => present,
		require => Package [ 'VirtualGL' ],
	}
	file { '/etc/kde/kdm/kdmrc':
		source  => 'puppet:///modules/hpc-puppet/kdmrc',
		ensure  => present,
		require => Package [ 'VirtualGL' ],
	}
	file { '/usr/share/config/kdm/kdmrc':
		source  => 'puppet:///modules/hpc-puppet/kdmrc',
		ensure  => present,
		require => Package [ 'VirtualGL' ],
	}
	
	exec { 'set-init-5':
		command => 'sed -i s/id:3/id:5/ /etc/inittab',
		onlyif  => "grep -q id:3 /etc/inittab",
		require => File [ '/etc/X11/xdm/Xservers' ],
	}

	exec { 'go-init-5':
		command => 'init 5',
		unless  => '[ -n "`ps -C Xorg | grep -v PID`" ]',
		require => Exec [ 'set-init-5' ],
	}
}
