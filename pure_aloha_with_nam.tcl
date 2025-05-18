# Filename: pure_aloha_with_nam.tcl

# Create a simulator instance
set ns [new Simulator]

# Trace file for analysis
set tracefile [open pure_aloha.tr w]
$ns trace-all $tracefile

# NAM file for animation
set namfile [open pure_aloha.nam w]
$ns namtrace-all $namfile

# Create nodes: 2 senders, 1 receiver
set s1 [$ns node]
set s2 [$ns node]
set r  [$ns node]

# Links between senders and receiver
$ns duplex-link $s1 $r 1Mb 10ms DropTail
$ns duplex-link $s2 $r 1Mb 10ms DropTail

# Position nodes for NAM visualization
$ns duplex-link-op $s1 $r orient right-down
$ns duplex-link-op $s2 $r orient right-up

# UDP agents and sink
set udp1 [new Agent/UDP]; $ns attach-agent $s1 $udp1
set udp2 [new Agent/UDP]; $ns attach-agent $s2 $udp2
set sink [new Agent/Null]; $ns attach-agent $r $sink

$ns connect $udp1 $sink
$ns connect $udp2 $sink

# CBR traffic
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512
$cbr1 set rate_ 100kb
$cbr1 attach-agent $udp1

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 512
$cbr2 set rate_ 100kb
$cbr2 attach-agent $udp2

# Random start times to simulate Pure ALOHA
for {set t 1.0} {$t < 10.0} {set t [expr {$t + rand()*2.0}]} {
    $ns at $t "$cbr1 start"
}
for {set t 1.1} {$t < 10.0} {set t [expr {$t + rand()*2.0}]} {
    $ns at $t "$cbr2 start"
}

# Define simulation end
$ns at 11.0 "finish"

# Finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    puts "Simulation complete. Trace: pure_aloha.tr | NAM: pure_aloha.nam"
    exec nam pure_aloha.nam &
    exit 0
}

# Run the simulation
$ns run



