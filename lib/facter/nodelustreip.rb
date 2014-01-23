Facter.add("nodelustreip") do
        setcode do
                Facter::Util::Resolution.exec("echo $((`hostname -s | sed -e s/node// -r -e s/^0+//`/255)).$((`hostname -s | sed -e s/node// -r -e s/^0+//`%255))")
        end
end
