# Simple Client-Server Communication in NS2

set ns [new Simulator]
set nf [open client_server.nam w]
$ns namtrace-all $nf

# Create client and server nodes
set client [$ns node]
set server [$ns node]

# Create a duplex link between client and server
$ns duplex-link $client $server 1Mb 10ms DropTail

# Create TCP agent on client, TCP sink on server
set tcp [new Agent/TCP]
$ns attach-agent $client $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $server $sink

# Connect client TCP agent to server sink
$ns connect $tcp $sink

# Attach FTP application to client TCP agent (simulates data transfer)
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Start/stop FTP (client to server)
$ns at 1.0 "$ftp start"
$ns at 3.0 "$ftp stop"

# Now, to simulate server sending data to client, reverse the roles:
set tcp2 [new Agent/TCP]
$ns attach-agent $server $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $client $sink2

$ns connect $tcp2 $sink2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

# Start/stop FTP (server to client)
$ns at 4.0 "$ftp2 start"
$ns at 6.0 "$ftp2 stop"

# Finish simulation
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam client_server.nam &
    exit 0
}
$ns at 7.0 "finish"

$ns run

