Facter.add("kernelreleaseunderscore") do
        setcode do
                Facter::Util::Resolution.exec("uname -r | sed s/-/_/g")
        end
end

