class hpc-puppet::visnode::driver {
	package { "kernel-devel-$kernelrelease":
                ensure => present,
        }
        package { "kernel-headers-$kernelrelease":
                ensure => present,
        }
	package { "dkms":
		ensure => present,
	}
	package { 'xorg-x11-drivers':
		ensure => absent,
	}
	package {'xorg-x11-drv-nouveau':
		ensure  => absent,
		require => Package [ 'xorg-x11-drivers' ],
	}

	exec {'remove-nouveau':
		command => "rm -rf /lib/modules/`uname -r`/kernel/drivers/gpu/drm/nouveau && dracut /boot/initramfs-$(uname -r).img.new $(uname -r) && mv -f /boot/initramfs-$(uname -r).img.new /boot/initramfs-$(uname -r).img",
		onlyif  => "test -f /lib/modules/`uname -r`/kernel/drivers/gpu/drm/nouveau/nouveau.ko",
		notify  => Exec [ 'reboot' ],
	}
        
	#TODO: set this to your gpu devices and provide appropriate driver files
	if $gpu == "G71"  { 	$nvpkg="NVIDIA-Linux-x86_64-304.88.run" }
	elsif $gpu == "GF100" {	$nvpkg="NVIDIA-Linux-x86_64-331.20.run" }
	else { notice ("Unknown GPU") }
	
	
        exec {'install-nvidia-driver':
                command => "wget -q http://hpc.lan/CUDA/$nvpkg -O /tmp/$nvpkg && chmod 755 /tmp/$nvpkg && /tmp/$nvpkg --silent -a --dkms && rm -f /tmp/$nvpkg",
                require => [ Exec ['install-distro-devtools'], 
                                Package [ "dkms" ],
                                Package [ "kernel-devel-$kernelrelease" ],
                                Package [ "kernel-headers-$kernelrelease" ],
				Exec [ 'remove-nouveau' ],
                        ],
                unless => "test -f /lib/modules/$kernelrelease/extra/nvidia.ko"
        }

	#needs extra option to make it think CRT is connected
	file { '/etc/X11/xorg.conf':
		source  => 'puppet:///modules/hpc-puppet/nvidia-xorg.conf',
		ensure  => present,
		require => Exec [ 'install-nvidia-driver' ],
	}

	#nvidia params for work with virtualGL
	file { '/etc/modprobe.d/virtualgl.conf':
		source => 'puppet:///modules/hpc-puppet/nvidia-module.conf',
		ensure => present,
		require => Exec [ 'install-nvidia-driver' ],
	}
}
