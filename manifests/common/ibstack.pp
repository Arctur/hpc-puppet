class hpc-puppet::common::ibstack ($mngmt=false) {

#add proper repo
file { '/etc/yum.repos.d/ofed.repo':
	source => "puppet:///modules/hpc-puppet/$infiniband.repo",
	ensure => present,
	mode => 0644,
}

# configure ib for IP
file { '/etc/sysconfig/network-scripts/ifcfg-ib0':
	content => template ('hpc-puppet/ifcfg-ib0.erb'),
	ensure => present,
	notify => Service ['network'],
}
# currently we are not using secondary port on dual-port ib adapters
file { '/etc/sysconfig/network-scripts/ifcfg-ib1':
	ensure => absent,
	notify => Service ['network'],
}

#install proper rpms (craptastic vendor rpms without proper dependencies)
case $infiniband {

	mlx: {
			$ibetcpkg = "mlnx-ofa_kernel"
			$ibpkglist = [ 'mpi-selector','knem',
				'ofed-scripts', 'libibverbs-utils', 'libmlx4', 'libnes',
				'librdmacm', 'mstflint' , 'libibmad', 'libmverbs', 
				'infiniband-diags', 'mxm', 'infinipath-psm', 'dapl', 
				'compat-dapl-devel', 'dapl-devel', 'dapl-utils', 'cc_mgr',
				'ar_mgr', 'qperf', 'mvapich2_gcc', 'librdmacm-devel', 
				'mpitests_mvapich2_gcc', 'mlnx-ofa_kernel', 'kernel-mft',
				'mlnxofed-docs', 'libibverbs', 'libmthca', 'libcxgb3', 
				'libipathverbs', 'librdmacm-utils', 'libibumad', 'mft',
				'opensm-libs', 'fca', 'ibacm', 'opensm', 'dump_pr', 'ibdump',
				'perftest', 'libmqe', 'openmpi_gcc', 'mpitests_openmpi_gcc', ]
			package { $ibpkglist:
				require => File ['/etc/yum.repos.d/ofed.repo'],
				ensure => 'latest',
			}
			package { 'ibutils':
				ensure => absent,
			}
			package { 'ibutils2':
				require => [ File ['/etc/yum.repos.d/ofed.repo'],
					Package [ 'ibutils' ],
					]		
			}
			case $ib_hca {
				InfiniHost: {
					#kernel ib_mthca has symbol version conflicts with ofed 2.0 modules
					#should we install ofed 1.5.4 for these old cards?
					package { 'kmod-mlnx-ofa_kernel':
						ensure => absent,
					}
				}
				ConnectX: {
					package { 'kmod-mlnx-ofa_kernel':
						require => File ['/etc/yum.repos.d/ofed.repo'],
						ensure => 'latest',
						notify => Exec ['depmod'],
					}
				}
			}
		}

	qlc: {
		$ibetcpkg = "kernel-ib"
		$ibpkglist = [ 'libibumad', 'librdmacm-utils', 'libibumad-compat', 'opensm-libs',
				'qperf', 'tmi', 'sdpnetstat', 'ofed-scripts', 'libibverbs-utils', 'opensm',
				'libibmad', 'librdmacm', 'libmthca', 'libibcommon-compat', 'libibumad-compat-2',
				'ibacm', 'ibutils', 'infinipath-libs', 'infinipath', 'libmlx4', 'libsdp',
				'intel-onesided', 'libibverbs', 'libibcm', 'libipathverbs', 'libibmad-compat',
				'infiniband-diags', 'intel-shmem', 'kernel-ib', ]
		package { $ibpkglist:
			require => File ['/etc/yum.repos.d/ofed.repo'],
			ensure  => 'latest',
			notify  => Exec [ 'depmod' ],
		}

		}
	}

	service { 'opensm':
        	ensure => $mngmt ? { true => 'running', false => 'stopped' },
        	enable => $mngmt ,
        	hasstatus => true,
        	hasrestart => true,
        	require => Package['opensm'],
        }

	#disable mlx5 and enable rdma loading here
	file { '/etc/infiniband/openib.conf':
		source  => "puppet:///modules/hpc-puppet/openib_$infiniband.conf",
		ensure  => present,
		require => Package [ "$ibetcpkg" ], 
	}
	service { 'openibd':
		name => $service_name,
		ensure => running,
		enable => true,
		require => File [ '/etc/infiniband/openib.conf' ],
	}
}
