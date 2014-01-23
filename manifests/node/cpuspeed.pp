class hpc-puppet::node::cpuspeed {
	#https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Power_Management_Guide/tuning_cpufreq_policy_and_speed.html
	package { 'cpuspeed':
		ensure => latest,
	}
	#check how ondemand behaves when jobs are running
	file { '/etc/sysconfig/cpuspeed':
		source => 'puppet:///modules/hpc-puppet/cpuspeed',
		ensure => present,
	}
	service { 'cpuspeed':
		ensure  => running,
		enable  => true,
		require => File [ '/etc/sysconfig/cpuspeed' ],
	}
}
