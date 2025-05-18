# Frame Relay-like WAN Simulation in NS2

set ns [new Simulator]
set nf [open frame_relay.nam w]
$ns namtrace-all $nf

# Create nodes: A, S1, S2, B
set A [$ns node]
set S1 [$ns node]
set S2 [$ns node]
set B [$ns node]

# Create WAN links (representing Frame Relay virtual circuits)
$ns duplex-link $A $S1 1Mb 20ms DropTail
$ns duplex-link $S1 $S2 512Kb 30ms DropTail
$ns duplex-link $S2 $B 1Mb 20ms DropTail

# Optional: Visual grouping in NAM
$ns duplex-link-op $A $S1 orient right-down
$ns duplex-link-op $S1 $S2 orient right
$ns duplex-link-op $S2 $B orient right-up

# Create UDP agent and attach to node A (sender)
set udp0 [new Agent/UDP]
$ns attach-agent $A $udp0

# Create Null agent and attach to node B (receiver)
set null0 [new Agent/Null]
$ns attach-agent $B $null0

# Connect sender to receiver through the switches
$ns connect $udp0 $null0

# Create CBR traffic generator and attach to UDP agent
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 500
$cbr0 set rate_ 100Kb

# Start/stop traffic
$ns at 1.0 "$cbr0 start"
$ns at 8.0 "$cbr0 stop"

# Finish simulation and launch NAM
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam frame_relay.nam &
    exit 0
}
$ns at 10.0 "finish"

$ns run



