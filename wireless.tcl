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
# Define values
# =======================

set val(packet_size) 512
set val(rate) 200kb
set val(run_time) 100       ;# simulation time
set val(start_time) 1.0 ;# start ftp connection time  

# ====================================================================
# Setting Phy Paramaters
#    - Description of each knob can be found in /ns-2.35/mac/wireless-phy.h 
# ====================================================================
Phy/WirelessPhy set bandwidth_ 1.5Mb
Phy/WirelessPhy set CSThresh_ 1.7615e-10 ; 
Phy/WirelessPhy set Pt_ 0.282

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
$node_(7) set Z 0

#node L

$node_(8) set X 250
$node_(8) set Y 200
$node_(8) set Z 0

# =======================
# Create UDP flow for a-h nodes
# =======================
set a_udp_agent [new Agent/UDP]
set h_null_agent [new Agent/NUll]

$ns attach-agent $node_(0) $a_udp_agent
$ns attach-agent $node_(7) $h_null_agent

$ns connect $a_udp_agent $h_null_agent

# =======================
# Create UDP flow for d-l nodes
# =======================
set d_udp_agent [new Agent/UDP]
set l_null_agent [new Agent/NUll]

$ns attach-agent $node_(3) $d_udp_agent
$ns attach-agent $node_(8) $l_null_agent

$ns connect $d_udp_agent $l_null_agent

# =======================
# Create CBR traffic for node a-h 
# =======================
set ah_cbr [new Application/Traffic/CBR]
$ah_cbr attach-agent $a_udp_agent
$ah_cbr set packetSize_ $val(packet_size)
$ah_cbr set rate_ $val(rate)

# =======================
# Create CBR traffic for node d-l
# =======================
set dl_cbr [new Application/Traffic/CBR]
$dl_cbr attach-agent $d_udp_agent
$dl_cbr set packetSize_ $val(packet_size)
$dl_cbr set rate_ $val(rate)
 
# =======================
# Running agents
# =======================

$ns at $val(start_time) "$a_udp start"
$ns at $val(run_time)   "$a_udp stop"

$ns at $val(start_time) "$d_udp start"
$ns at $val(run_time)   "$d_udp stop"


for {set i 0} {$i < $opt(size)} {incr i} {
    $ns initial_node_pos $node_($i) 40
    $ns at $val(run_time) "$node_($i) reset";
}

$ns at $val(run_time) "finish"
$ns at [expr $val(run_time) + 0.1] "$ns halt"

#run the connection

$ns run