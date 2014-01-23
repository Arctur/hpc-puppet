class hpc-puppet::login ($hpclanif="eth1", $lustreif="eth2") {
	include 'hpc-puppet::common::distro-devtools'
	include 'hpc-puppet::common::munge'
	include 'hpc-puppet::common::gmond' 
	include 'hpc-puppet::common::icr_libs'
	include 'hpc-puppet::common::icr_interactive'
	include 'hpc-puppet::common::ssh'
	include 'hpc-puppet::common::ldapclient'
	include 'hpc-puppet::node::nfs'
	include 'hpc-puppet::node::torqueclient'
	#TODO: set this to interface over which lustre is accessible
	class { 'hpc-puppet::lustre::client': lif => "$lustreif" } 

	#what users want:
	$userpkgs = [ 'nano', 'joe' ]

	package { $userpkgs:
		ensure => installed,
	}

	#TODO: network config: eth0 is defined at install time
	file { "/etc/sysconfig/network-scripts/ifcfg-$hpclanif":
		content => template ('hpc-puppet/loginvm_lanif.erb'),
		notify  => Service [ 'network' ],
	}
	file { "/etc/sysconfig/network-scripts/ifcfg-$lustreif":
		content => template ('hpc-puppet/loginvm_lustreif.erb'),
		notify  => Service [ 'network' ],
	}
}

