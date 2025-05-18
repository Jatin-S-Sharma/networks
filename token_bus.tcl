# Token Bus LAN Protocol Simulation in NS2 with NAM Visualization

# 1. Initialize Simulator and Trace Files
set ns [new Simulator]
set nam_file [open token_bus.nam w]
$ns namtrace-all $nam_file

# 2. Create Nodes and Connect via LAN (Bus Topology)
set node_count 4
for {set i 0} {$i < $node_count} {incr i} {
    set node($i) [$ns node]
}
set lan [$ns newLan "$node(0) $node(1) $node(2) $node(3)" 1Mb 10ms -macType Mac/802_3]

# 3. Attach UDP/CBR (Sender) and Null (Receiver) Agents to Each Node
for {set i 0} {$i < $node_count} {incr i} {
    set udp($i) [new Agent/UDP]
    $ns attach-agent $node($i) $udp($i)

    set null($i) [new Agent/Null]
    $ns attach-agent $node($i) $null($i)

    set cbr($i) [new Application/Traffic/CBR]
    $cbr($i) attach-agent $udp($i)
    $cbr($i) set packetSize_ 512
    $cbr($i) set rate_ 100Kb
}

# 4. Connect Each Node's UDP Agent to the Next Node's Null Agent (Ring for Token Passing)
for {set i 0} {$i < $node_count} {incr i} {
    set next [expr ($i + 1) % $node_count]
    $ns connect $udp($i) $null($next)
}

# 5. Token Passing Procedure (Only One Node Sends at a Time)
proc pass_token {current} {
    global ns cbr node_count
    $cbr($current) start
    $ns at [expr [clock seconds] + 1.0] "$cbr($current) stop"
    set next [expr ($current + 1) % $node_count]
    $ns at [expr [clock seconds] + 1.1] "pass_token $next"
}

# 6. Start Token Passing from Node 0
$ns at 1.0 "pass_token 0"

# 7. Finish Simulation and Launch NAM
proc finish {} {
    global ns nam_file
    $ns flush-trace
    close $nam_file
    exec nam token_bus.nam &
    exit 0
}
$ns at 10.0 "finish"

# 8. Run Simulation
$ns run



