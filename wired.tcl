# Create a simulator object
set ns [new Simulator]

# Open trace and NAM files
set tracefile [open out.tr w]
$ns trace-all $tracefile

set namfile [open out.nam w]
$ns namtrace-all $namfile

# Create nodes
set n0 [$ns node]
set n1 [$ns node]

# Create a duplex link between nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

# Attach TCP agent to n0
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

# Attach TCPSink agent to n1
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

# Connect TCP to TCPSink
$ns connect $tcp $sink

# Attach FTP application to TCP agent
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Start FTP traffic
$ns at 0.5 "$ftp start"

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
$ns at 5.0 "finish"

# Run simulation
$ns run

