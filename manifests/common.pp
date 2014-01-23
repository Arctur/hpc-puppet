#some common actions that are called from various places
#TODO: but if you have wider puppet deployment, you probably already have them defined
class hpc-puppet::common {
	exec { 'reboot':
                command => '/sbin/reboot',
                refreshonly => true,
        }
        exec { 'sysctl':
                command => 'sysctl -p',
                refreshonly => true,
        }
        exec { 'depmod':
                command => 'depmod -ae',
                refreshonly => true,
        }
}
