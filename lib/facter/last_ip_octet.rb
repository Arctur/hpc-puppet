Facter.add("lastipoctet") do
	setcode do
		Facter::Util::Resolution.exec("/sbin/ifconfig eth0 | grep 'inet addr:' | awk '{ print $2 }' | cut -d'.' -f4")
	end
end
