class hpc-puppet::node::torqueclient {
        package { 'torque-client':
                ensure => latest,
                }
        file { '/etc/profile.d/pbsenv.sh':
                source => 'puppet:///modules/hpc-puppet/pbsenv.sh',
                ensure => present,
        }
}
