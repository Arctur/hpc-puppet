class hpc-puppet::common::icr_interactive {
	#6.3.5 X11 tools
	$icrx11toolspkglist = [ 'glx-utils', 'xorg-x11-apps', 'xorg-x11-utils',
				'xorg-x11-server-utils', 'xterm', 'xorg-x11-xauth', ]
	package { $icrx11toolspkglist:
		ensure => latest,
	}

	#6.3.6 web browser
	package { 'firefox':
		ensure => latest,
	}

	#6.3.7 pdf viewer (this also pulls in gnome-desktop, which is ok)
	package { 'evince':
		ensure => latest,
	}
}
