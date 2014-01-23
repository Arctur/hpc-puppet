class hpc-puppet::node ($mngmtif="eth0", $lustreif="eth0.16", $hpclanif="eth1") {
	include 'hpc-puppet::munge'
	include 'hpc-puppet::common::icr_libs'
	include 'hpc-puppet::common::ldapclient'
	include 'hpc-puppet::common::gmond'
	class { 'hpc-puppet::node::net': $mngmtif => "eth0", $lustreif => "eth0.16", $hpclanif => "eth1", }
	include 'hpc-puppet::node::ssh'
	include 'hpc-puppet::node::nfs'
	include 'hpc-puppet::node::cpuspeed'
	include 'hpc-puppet::grid::worker'
	
	#enforce some ordering
	Class [ 'hpc-puppet::node::net' ] -> Class [ 'hpc-puppet::node::nfs' ]

	case $hostname {
	#TODO: fatnode as an example of how to implement exceptions
		'fatnode0': {
			class { 'hpc-puppet::lustre::client': lif => "eth4" }
        		class { 'hpc-puppet::common::ibstack': mngmt => true }
			include 'hpc-puppet::node::torque'
		}
		default: {
			class { 'hpc-puppet::lustre::client': lif => "$lustreif" }
			case $gpu {
				#visualisation nodes only, implement compute nodes if/when we get them
				'G71','GF100': {
					include 'hpc-puppet::common::distro-devtools'
					class { 'hpc-puppet::node::torque': interactive => "yes" }
					include 'hpc-puppet::visnode'
					include 'hpc-puppet::visnode::driver'
					include 'hpc-puppet::visnode::tools'
					Class [ 'hpc-puppet::visnode' ] ->  Class [ 'hpc-puppet::visnode::driver' ] -> Class ['hpc-puppet::visnode::tools']
				}
				'amd': {}
				default: {}
			default: {
				include 'hpc-puppet::node::torque'
	        		class { 'hpc-puppet::common::ibstack': mngmt => false }
				}
			}
		}
	}
}

