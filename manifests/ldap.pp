class hpc-puppet::ldap {
	#TODO: manually configure network on this node
	#TODO: handle config files manually
	#TODO: manually bootstrap ldap 
	#(can someone suggest decent set of puppet scripts for managing ldaps?)
	package { 'openldap-servers':
		ensure => latest,
	}
	service { 'slapd':
		enable  => true,
		ensure  => running,
		require => Package [ 'openldap-servers' ],
	}
	package { 'httpd':
		ensure => latest,
	}
        service {'httpd':
                ensure => running,
                enable => true,
		require => Package [ 'httpd' ],
        }
	package { 'php-ldap':
		ensure => latest,
	}
	package { 'phpldapadmin':
		ensure  => latest,
		require => [ Package [ 'php-ldap' ], Service [ 'httpd' ], ],
	}
}

