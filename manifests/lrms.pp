class hpc-puppet::lrms {
	#TODO: manually configure network on this node
	include 'hpc-puppet::common::ldapclient'
	include 'hpc-puppet::common::munge'
	include 'hpc-puppet::lrms::torque'

	#TODO: provide root ssh public key
        ssh_authorized_key { "headnode":
                user => 'root',
                type => 'ssh-rsa',
                name => 'hpc-root',
                key => '...',
                ensure => present,
        }
}

