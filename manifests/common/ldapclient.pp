class hpc-puppet::common::ldapclient {
	package { 'openldap-clients':
		ensure => latest,
	}
	package { 'nss-pam-ldapd':
		ensure => latest,
	}
	package { 'pam_ldap':
		ensure => latest,
	}
	file { '/etc/openldap/ldap.conf':
		source => 'puppet:///modules/hpc-puppet/ldap.conf',
		require => Package [ 'openldap-clients' ],
	}
	file { '/etc/nslcd.conf':
		source => 'puppet:///modules/hpc-puppet/nslcd.conf',
		mode => 0600,
		require => Package [ 'nss-pam-ldapd' ],
	}
	file { '/etc/pam_ldap.conf':
		source  => 'puppet:///modules/hpc-puppet/pam_ldap.conf',
		require => Package [ 'pam_ldap' ],
	}
	service { 'nslcd':
		ensure => running,
		enable => true,
		require => File [ '/etc/nslcd.conf' ],
	}
	file { '/etc/nsswitch.conf':
		source => 'puppet:///modules/hpc-puppet/nsswitch.conf',
	}

	#also takes care of creating new homedirs
	file { '/etc/pam.d/system-auth-ac':
		source => 'puppet:///modules/hpc-puppet/pam-systemauth'
	}
}

