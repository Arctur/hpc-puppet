Facter.add("mdsip") do
        setcode do
                Facter::Util::Resolution.exec("echo $((`hostname -s | sed s/Lustre2MDS//`+197))")
        end
end

