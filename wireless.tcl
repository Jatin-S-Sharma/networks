# Minimal Wireless NS2 Script with God and NAM

# Simulation parameters
set val(chan)           Channel/WirelessChannel
set val(prop)           Propagation/TwoRayGround
set val(netif)          Phy/WirelessPhy
set val(mac)            Mac/802_11
set val(ifq)            Queue/DropTail/PriQueue
set val(ll)             LL
set val(ant)            Antenna/OmniAntenna
set val(ifqlen)         50
set val(nn)             2
set val(rp)             DSDV
set val(x)              500
set val(y)              500
set val(stop)           10.0

# Create Simulator
set ns [new Simulator]

# Open trace and NAM files
set tracefile [open out.tr w]
$ns trace-all $tracefile
set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)

# Create topology object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God object (CORRECT WAY)
set god_ [create-god $val(nn)]

# Create shared wireless channel
set chan_1_ [new $val(chan)]

# Configure wireless nodes
$ns node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel $chan_1_ \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace ON

# Create nodes
set n0 [$ns node]
set n1 [$ns node]

# Set node positions
$n0 set X_ 100
$n0 set Y_ 100
$n0 set Z_ 0.0
$n1 set X_ 200
$n1 set Y_ 200
$n1 set Z_ 0.0

# Update node positions in NAM
$ns initial_node_pos $n0 20
$ns initial_node_pos $n1 20

# Create UDP agent and attach to n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create Null agent and attach to n1
set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

# Connect UDP agent to Null agent
$ns connect $udp0 $null0

# Create CBR traffic generator and attach to UDP agent
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 512
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# Start CBR traffic at 1.0s
$ns at 1.0 "$cbr0 start"

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}

# Schedule finish
$ns at $val(stop) "finish"

# Run simulation
$ns run

