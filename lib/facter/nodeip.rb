Facter.add("nodeip") do
        setcode do
		#this is super ugly
                Facter::Util::Resolution.exec("[ $(hostname -s) = \"square\" ] && echo \"128.254\" || echo $((129+$((`hostname -s | sed -e s/node// -r -e s/^0+//`/255)))).$((`hostname -s | sed -e s/node// -r -e s/^0+//`%255))")
        end
end
