if FileTest.exists?("/proc/drbd")
  result = {}

  Thread::exclusive do
    File.readlines("/proc/drbd").each do |l|
      if l =~ /(\d+): cs:Unconfigured/
        device = $1

        result["drbdconnectionstate#{device}"] = "Unconfigured"
      elsif l =~ /(\d+): cs:(\w+) st:(\w+)\/(\w+) ld:(\w+)/
        device = $1
        connectionstate = $2
        localstate = $3
        peerstate = $4
        localdiskstate = $5

        result["drbdconnectionstate#{device}"] = connectionstate
        result["drbdlocalstate#{device}"] = localstate
        result["drbdpeerstate#{device}"] = peerstate
        result["drbdlocaldiskstate#{device}"] = localdiskstate
      elsif l =~ /(\d+): cs:(\w+) (st|ro):(\w+)\/(\w+) ds:(\w+)\/(\w+)/
        device = $1
        connectionstate = $2
        localstate = $4
        peerstate = $5
        localdiskstate = $6
        peerdiskstate = $7

        result["drbdconnectionstate#{device}"] = connectionstate
        result["drbdlocalstate#{device}"] = localstate
        result["drbdpeerstate#{device}"] = peerstate
        result["drbdlocaldiskstate#{device}"] = localdiskstate
        result["drbdpeerdiskstate#{device}"] = peerdiskstate
      end
    end
  end

  result.each { |name, fact|
    Facter.add(name) do
       setcode do
         fact
       end
    end
  }
end
