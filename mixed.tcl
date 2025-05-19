# Minimal Hybrid Wired-Wireless NS2 Script with NAM

set ns [new Simulator]
set tracefile [open out.tr w]
$ns trace-all $tracefile
set namfile [open out.nam w]
$ns namtrace-all $namfile

# Topology and wireless channel
set topo [new Topography]
$topo load_flatgrid 500 500
set chan_ [new Channel/WirelessChannel]
set god_ [create-god 1]

# Wireless node config
$ns node-config -adhocRouting DSDV \
    -llType LL \
    -macType Mac/802_11 \
    -ifqType Queue/DropTail/PriQueue \
    -ifqLen 50 \
    -antType Antenna/OmniAntenna \
    -propType Propagation/TwoRayGround \
    -phyType Phy/WirelessPhy \
    -channel $chan_ \
    -topoInstance $topo \
    -wiredRouting ON

# Nodes
set n0 [$ns node]      ;# Wired node
set bs [$ns node]      ;# Base station/gateway
set n1 [$ns node]      ;# Wireless node

# Set positions for wireless nodes
$bs set X_ 250; $bs set Y_ 250; $bs set Z_ 0
$n1 set X_ 100; $n1 set Y_ 100; $n1 set Z_ 0
$ns initial_node_pos $bs 20
$ns initial_node_pos $n1 20

# Wired link between n0 and base station
$ns duplex-link $n0 $bs 5Mb 2ms DropTail

# Traffic: UDP from n0 to n1
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n1 $null
$ns connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns at 1.0 "$cbr start"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}
$ns at 10.0 "finish"
$ns run

