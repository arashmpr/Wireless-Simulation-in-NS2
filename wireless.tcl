Mac/802_11 set bandwidth [lindex $argv 0]

# =======================
# Define options
# =======================

set opt(chan) Channel/WirelessChannel
set opt(prop) Propagation/TwoRayGround
set opt(ll) LL 
set opt(ifq) Queue/DropTail/PriQueue
set opt(ifqlen) 50                      ;# max packet size
set opt(netif) Phy/WirelessPhy 
set opt(mac) Mac/802_11 
set opt(ant) Antenna/OmniAntenna
set opt(rp) AODV 

set opt(size) 9

# =======================
# Define NS simulator
# =======================

set ns [new Simulator]

# =======================
# Define trace file and nam file
# =======================

set trace_file [open wireless_trace_file.tr w]
$ns trace-all $trace_file

set nam_file [open wireless_nam_file w]
$ns namtrace-all-wireless $nam_file 500 500

# =======================
# Define Finish proc
# =======================
proc finish {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $trace_file
    close $nam_file
    exit 0
}

set val(run_time) 100       ;# simulation time
set val(start_ftp_time) 1.0 ;# start ftp connection time    

# =======================
# Create topology object
# =======================

set topo [new Topography]
$topo load_flatgrid 500 500

# =======================
# Create God object
# =======================

create-god $opt(size)

$ns node-config -adhocRouting $opt(rp) \
                -llType $opt(ll) \
                -macType $opt(mac) \
                -ifqType $opt(ifq) \
                -ifqLen $opt(ifqlen) \
                -antType $opt(ant) \
                -propType $opt(prop) \
                -phyType $opt(netif) \
                -channelType $opt(chan) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF

# =======================
# Create Nodes
# =======================

for {set i 0} {$i < $opt(size)} {incr i} {
    set node_($i) [$ns node]
    $node_($i) random-motion 0 ;#Creating nodes manually

}

# =======================
# Create Node's attribute
# =======================

#node A

$node_(0) set X 100
$node_(0) set Y 50
$node_(0) set Z 0

#node B

$node_(1) set X 50
$node_(1) set Y 150
$node_(1) set Z 0

#node C

$node_(2) set X 150
$node_(2) set Y 100
$node_(2) set Z 0

#node D

$node_(3) set X 100
$node_(3) set Y 250
$node_(3) set Z 0

#node E

$node_(4) set X 150
$node_(4) set Y 200
$node_(4) set Z 0

#node F

$node_(5) set X 200
$node_(5) set Y 200
$node_(5) set Z 0

#node G

$node_(6) set X 200
$node_(6) set Y 100
$node_(6) set Z 0

#node H

$node_(7) set X 250
$node_(7) set Y 100
$node_(7)) set Z 0

#node L

$node_(8) set X 250
$node_(8) set Y 200
$node_(8)) set Z 0

# =======================
# Create Agents
# =======================

#setting the tcp and sink agent
set a_source [new Agent/TCP]
set h_sink [new Agent/TCPSink]

set d_source [new Agent/TCP]
set l_sink [new Agent/TCPSink]

#attaching source and sink agents to nodes

$ns attach-agent $n0 $a_source
$ns attach-agent $n7 $h_sink

$ns attach-agent $n2 $d_source
$ns attach-agent $n8 $l_sink

$ns connect $a_source $h_sink
$ns connect $d_source $l_sink

set ah_ftp [new Application/FTP]
set dl_ftp [new Application/FTP]

$ah_ftp attach-agent $a_source
$dl_ftp attach-agent $d_source

#run ftp connection
$ns at $val(start_ftp_time) "$ah_ftp running..."
$ns at $val(start_ftp_time) "$dl_ftp running..."

#run the connection

$ns run