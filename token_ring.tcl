# Token Ring Protocol Simulation in NS2 with NAM

# 1. Initialize Simulator and NAM Trace
set ns [new Simulator]
set nf [open token_ring.nam w]
$ns namtrace-all $nf

# 2. Create 4 Nodes
set node_count 4
for {set i 0} {$i < $node_count} {incr i} {
    set n($i) [$ns node]
}

# 3. Connect Nodes in a Ring (Duplex Links)
for {set i 0} {$i < $node_count} {incr i} {
    set next [expr ($i + 1) % $node_count]
    $ns duplex-link $n($i) $n($next) 10Mb 10ms DropTail
}

# 4. Attach UDP/CBR (Sender) and Null (Receiver) Agents
for {set i 0} {$i < $node_count} {incr i} {
    set udp($i) [new Agent/UDP]
    set null($i) [new Agent/Null]
    $ns attach-agent $n($i) $udp($i)
    $ns attach-agent $n($i) $null($i)
    set cbr($i) [new Application/Traffic/CBR]
    $cbr($i) attach-agent $udp($i)
    $cbr($i) set packetSize_ 512
    $cbr($i) set rate_ 100Kb
}

# 5. Now connect agents (after all agents are created)
for {set i 0} {$i < $node_count} {incr i} {
    # Each node sends to the node two hops ahead, for demonstration
    set recv [expr ($i + 2) % $node_count]
    $ns connect $udp($i) $null($recv)
}

# 6. Token Passing Logic: Only one node sends at a time
proc pass_token {i} {
    global ns cbr node_count
    $cbr($i) start
    $ns at [expr [clock seconds] + 1.0] "$cbr($i) stop"
    set next [expr ($i + 1) % $node_count]
    $ns at [expr [clock seconds] + 1.1] "pass_token $next"
}

# 7. Start Token Passing from Node 0
$ns at 1.0 "pass_token 0"

# 8. Finish Simulation and Launch NAM
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam token_ring.nam &
    exit 0
}
$ns at 8.0 "finish"

# 9. Run Simulation
$ns run

