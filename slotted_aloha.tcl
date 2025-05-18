# slotted_aloha.tcl
#ek fixed time par packet send , therfore no collision
set ns [new Simulator]

set tracefile [open slotted_aloha.tr w]
$ns trace-all $tracefile

set namfile [open slotted_aloha.nam w]
$ns namtrace-all $namfile

# Create nodes
set s1 [$ns node]
set s2 [$ns node]
set r  [$ns node]

# Create duplex links
$ns duplex-link $s1 $r 1Mb 10ms DropTail
$ns duplex-link $s2 $r 1Mb 10ms DropTail

# Attach UDP and Null agents
set udp1 [new Agent/UDP]
$ns attach-agent $s1 $udp1
set udp2 [new Agent/UDP]
$ns attach-agent $s2 $udp2
set sink [new Agent/Null]
$ns attach-agent $r $sink

$ns connect $udp1 $sink
$ns connect $udp2 $sink

# Setup CBR traffic
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512
$cbr1 set rate_ 100kb
$cbr1 attach-agent $udp1

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 512
$cbr2 set rate_ 100kb
$cbr2 attach-agent $udp2

# Slotted ALOHA: start traffic exactly at slot intervals (1s slots)
for {set t 1} {$t <= 10} {incr t 1} {
    $ns at $t "$cbr1 start"
}
for {set t 1} {$t <= 10} {incr t 1} {
    # Offset second sender by 0.5 sec within slot to simulate random access
    set offset [expr {$t + 0.5}]
    $ns at $offset "$cbr2 start"
}

# End simulation
$ns at 12 "finish"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    puts "Simulation done. Trace saved to slotted_aloha.tr"
    exec nam slotted_aloha.nam &
    exit 0
}

$ns run



