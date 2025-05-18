# X.25-like WAN Simulation in NS2 with NAM Visualization

# 1. Initialize Simulator and NAM Trace
set ns [new Simulator]
set nf [open x25.nam w]
$ns namtrace-all $nf

# 2. Create Nodes: Sender (A), Routers (R1, R2), Receiver (B)
set A [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set B [$ns node]

# 3. Create WAN Links (simulate X.25 virtual circuits)
$ns duplex-link $A $R1 512Kb 40ms DropTail
$ns duplex-link $R1 $R2 256Kb 60ms DropTail
$ns duplex-link $R2 $B 512Kb 40ms DropTail

# Optional: Set link orientation for NAM visualization
$ns duplex-link-op $A $R1 orient right-down
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R2 $B orient right-up

# 4. Create TCP Agent (Sender) and TCPSink Agent (Receiver)
set tcp0 [new Agent/TCP]
$ns attach-agent $A $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $B $sink0

# 5. Connect TCP Agent to TCPSink Agent
$ns connect $tcp0 $sink0

# 6. Create FTP Application and Attach to TCP Agent
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# 7. Start and Stop FTP Traffic
$ns at 1.0 "$ftp0 start"
$ns at 8.0 "$ftp0 stop"

# 8. Finish Simulation and Launch NAM
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam x25.nam &
    exit 0
}
$ns at 10.0 "finish"

# 9. Run Simulation
$ns run



