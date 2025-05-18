# Minimal Distance Vector Routing (DV) Simulation in NS2

set ns [new Simulator]
set nf [open dv.nam w]
$ns namtrace-all $nf

# Create nodes
for {set i 0} {$i < 5} {incr i} { set n($i) [$ns node] }

# Topology
$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 512Kb 20ms DropTail
$ns duplex-link $n(2) $n(3) 1Mb 10ms DropTail
$ns duplex-link $n(3) $n(4) 512Kb 20ms DropTail
$ns duplex-link $n(0) $n(4) 256Kb 50ms DropTail
$ns duplex-link $n(1) $n(4) 256Kb 30ms DropTail

# Enable Distance Vector Routing
$ns rtproto DV

# TCP traffic from n0 to n3
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $n(0) $tcp
$ns attach-agent $n(3) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 1.0 "$ftp start"
$ns at 8.0 "$ftp stop"

proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam dv.nam &
    exit 0
}
$ns at 10.0 "finish"

$ns run

