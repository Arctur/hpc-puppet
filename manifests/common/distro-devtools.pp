class hpc-puppet::common::distro-devtools {
#install development tools rpm group 
	exec { 'install-distro-devtools':
		command => 'yum -y groupinstall "Development Tools"',
		unless => 'rpm -q gcc',
	}

}
