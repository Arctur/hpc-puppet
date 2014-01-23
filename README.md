hpc-puppet
==========

Puppet scripts to deploy fully functional HPC cluster from public repos



When you're faced with setting up a HPC system, you have three options:

1. buy commercial package for $alot that does all the magic for you
2. get free package like Rocks that does all the magic for you
3. roll your own and have complete understanding & control of your system

This repo is an attempt at #3.

Puppet enables us to describe our magic in a readable way.



We assume:

1. that you have installation infrastructure like cobbler already in place
2. that you have sufficient understanding of how HPC pieces fit together
3. that you have sufficient puppet skills to adjust this to your specific needs
4. that you name nodes like nodeNNN, since we calculate node IP from NNN
5. that you don't have petascale systems, but only smallish (few racks)
 "industry" sized system

Here's what we offer:
* HPC cluster built on top of RHEL based distro (most likely CentOS)
* IntelClusterReady software compliance (you need to get Intel sw yourself)
* dedicated nfs4 server
* dedicated node to build software, using easybuild
* dedicated login node
* dedicated queue manager node with torque+maui
* compute nodes with Qlogic and Mellanox Infiniband support
* lustre as parallel filesystem with failover MDS
* nordugrid ARC as grid middleware
* turbovnc+virtualGL for remote visualisation needs

Disclaimer: These scripts are a subset of what runs on our production cluster.
Much has been redacted and generalized to allow for more clean definition of
various roles.
Our prod includes iptables rules for every service and hosts, which are
specific to us and therefore ommited here.
Our prod has separate networks for puppet, hpc lan, external access, lustre and 
infiniband. Much of this is simplified here.
Our prod has custom tools deployed to do accounting and billing. None of that is
included here.
This also means there could be typos and/or other errors present.


What you need to do before you apply this:
* make sure your kickstart sets up all required yum repositories (el6, epel6)
* fetch some packages to your local repositories (lustre, ofed, nvidia drivers,
  turbovnc, virtualgl)
* probably rebuild some to match your kernel versions or drop files at
  different locations
* generate and/or provide ssh keys, munge key
* grep -r TODO . and fill in your data to describe your env
* review files and templates and adjust them to your needs (ip adresses...)
* review facts and adjust them to your needs (at least ip addressing ones)

There are over 70 TODO places to fill in, so take your time.

Of course you don't need to apply all of these, you can take out only the
parts that are interesting for you.

After you're done and there are no TODOs left, you can apply these to your
nodes:

# queue server
node 'pbs.hpc.lan' {
	include 'hpc-puppet'
	include 'hpc-puppet::lrms'
}

#sw build node
node 'swbuilder.hpc.lan' {
	include 'hpc-puppet'
	include 'hpc-puppet::swbuilder'
}

#ldap server
node 'ldap.hpc.lan' {
	include 'hpc-puppet::ldap'
}

#nfs server
node 'nfs.hpc.lan' {
	include 'hpc-puppet::nfshost'
}

#grid gateway
node 'gridgw.hpc.lan' {
	include 'hpc-puppet'
	include 'hpc-puppet::grid::gateway'
}

#login node
node 'login.hpc.lan {
	include 'hpc-puppet'
	class { 'hpc-puppet::login': $hpclanif => "eth1", $lustreif => "eth2" }
}

#compute nodes
node /node[0-9][0-9][0-9].hpc.lan/ {
	include 'hpc-puppet'
	class { 'hpc-puppet::node': $mngmtif => "eth0", $lustreif => "eth0.16", $hpclanif => "eth1", }
	#if compute node has gpu, this will configure it as interactive remote visualisation node
}

#lustre servers
node /mds[12].hpc.lan/ {
	include 'hpc-puppet'
	include 'hpc-puppet::lustre::server'
	include 'hpc-puppet::lustre::mds'
}

node /oss[0-9][0-9].hpc.lan/ {
	include 'hpc-puppet'
	include 'hpc-puppet::lustre::server'
	inlcude 'hpc-puppet::lustre::oss'
}

What is missing here is a node that runs gmetad and ganglia web frontend
and complete monitoring set (nagios et al), but I believe these are too site
specific and as such beyond the scope of this little project. However you have
a beginning of that available under mon subdir.

If you are interested in this and would like to provide feedback or request
support, we're reachable at hpc@arctur.si.
