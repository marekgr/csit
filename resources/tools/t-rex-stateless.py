#!/usr/bin/python

# Copyright (c) 2016 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This script uses T-REX stateless API to drive t-rex instance.

Requirements:
- T-REX: https://github.com/cisco-system-traffic-generator/trex-core 
 - compiled and running T-REX process (eg. ./t-rex-64 -i -c 4)
 - trex_stl_lib.api library
- Script must be executed on a node with T-REX instance
- 2 interfaces must be configured in configuretion file /etc/trex_cfg.yaml

##################### Example of /etc/trex_cfg.yaml ##########################
- port_limit      : 2 # numbers of ports to use
  version         : 2
  interfaces      : ["84:00.0","84:00.1"] # PCI address of interfaces
  port_info       :  # set eth mac addr 
          - dest_mac        :   [0x90,0xe2,0xba,0x1f,0x97,0xd5]  # port 0
            src_mac         :   [0x90,0xe2,0xba,0x1f,0x97,0xd4]
          - dest_mac        :   [0x90,0xe2,0xba,0x1f,0x97,0xd4]  # port 1
            src_mac         :   [0x90,0xe2,0xba,0x1f,0x97,0xd5]
##############################################################################

Functionality:
1. Configure traffic on running T-REX instance
2. Clear statistics on all ports
3. Ctart traffic with specified duration
4. Print statistics to stdout

"""


import sys, getopt
sys.path.insert(0, "/opt/trex-core-1.91/scripts/automation/trex_control_plane/stl/")

from trex_stl_lib.api import *

import dpkt
import json
import string

def generate_payload(length):
    word = ''
    alphabet_size = len(string.letters)
    for i in range(length):
        word += string.letters[(i % alphabet_size)]
    return word

def create_packets(traffic_options, frame_size=64):

    if frame_size < 64:
        print "Packet min. size is 64B"
        sys.exit(2)

    fsize_no_fcs = frame_size - 4 # no FCS

    #p1_src_mac = traffic_options['p1_src_mac']
    #p1_dst_mac = traffic_options['p1_dst_mac']
    p1_src_start_ip = traffic_options['p1_src_start_ip']
    p1_src_end_ip = traffic_options['p1_src_end_ip']
    p1_dst_start_ip = traffic_options['p1_dst_start_ip']
    #p1_dst_end_ip = traffic_options['p1_dst_end_ip']
    #p2_src_mac = traffic_options['p2_src_mac']
    #p2_dst_mac = traffic_options['p2_dst_mac']
    p2_src_start_ip = traffic_options['p2_src_start_ip']
    p2_src_end_ip = traffic_options['p2_src_end_ip']
    p2_dst_start_ip = traffic_options['p2_dst_start_ip']
    #p2_dst_end_ip = traffic_options['p2_dst_end_ip']

    base_pkt_a = Ether()/IP(src=p1_src_start_ip, dst=p1_dst_start_ip)
    base_pkt_b = Ether()/IP(src=p2_src_start_ip, dst=p2_dst_start_ip)

    vm1 = CTRexScRaw([STLVmTupleGen(ip_min=p1_src_start_ip, ip_max=p1_src_end_ip,
                                    name="tuple"), # define tuple gen

                      STLVmWrFlowVar(fv_name="tuple.ip", pkt_offset="IP.src"), # write ip to packet IP.src
                      STLVmFixIpv4(offset="IP"),                               # fix checksum
                     ]
                     , split_by_field="tuple") # split to cores base on the tuple generator
 
    vm2 = CTRexScRaw([STLVmTupleGen(ip_min=p2_src_start_ip, ip_max=p2_src_end_ip,
                                    name="tuple"), # define tuple gen

                      STLVmWrFlowVar(fv_name="tuple.ip", pkt_offset="IP.src"), # write ip to packet IP.src
                      STLVmFixIpv4(offset="IP"),                               # fix checksum
                     ]
                     , split_by_field="tuple") # split to cores base on the tuple generator

    pkt_a = STLPktBuilder(pkt=base_pkt_a/generate_payload(fsize_no_fcs-len(base_pkt_a)), vm=vm1)
    pkt_b = STLPktBuilder(pkt=base_pkt_b/generate_payload(fsize_no_fcs-len(base_pkt_b)), vm=vm2)

    return(pkt_a, pkt_b)

def simple_burst(pkt_a, pkt_b, duration=10, rate="1mpps",
                 warmup=True, warmup_time=5):

    # create client
    c = STLClient()
    passed = True

    try:
        # turn this on for some information
        #c.set_verbose("high")

        # create two streams
        s1 = STLStream(packet=pkt_a,
                       mode=STLTXCont(pps=100))

        # second stream with a phase of 10ns (inter stream gap)
        s2 = STLStream(packet=pkt_b,
                       isg=10.0,
                       mode=STLTXCont(pps=100))


        # connect to server
        c.connect()

        # prepare our ports (my machine has 0 <--> 1 with static route)
        c.reset(ports=[0, 1])

        # add both streams to ports
        c.add_streams(s1, ports=[0])
        c.add_streams(s2, ports=[1])

        #warmup phase
        if warmup == True:
            c.clear_stats()
            c.start(ports=[0, 1], mult=rate, duration=warmup_time)
            c.wait_on_traffic(ports=[0, 1])
            stats = c.get_stats()
            print stats
            print "#####warmup statistics#####"
            print json.dumps(stats, indent=4,
                             separators=(',', ': '), sort_keys=True)
            lost_a = stats[0]["opackets"] - stats[1]["ipackets"]
            lost_b = stats[1]["opackets"] - stats[0]["ipackets"]

            print "\npackets lost from 0 --> 1:   {0} pkts".format(lost_a)
            print "packets lost from 1 --> 0:   {0} pkts".format(lost_b)


        # clear the stats before injecting
        c.clear_stats()

        # choose rate and start traffic
        c.start(ports=[0, 1], mult=rate, duration=duration)

        # block until done
        c.wait_on_traffic(ports=[0, 1])

        # read the stats after the test
        stats = c.get_stats()

        print "#####statistics#####"
        print json.dumps(stats, indent=4,
                         separators=(',', ': '), sort_keys=True)

        lost_a = stats[0]["opackets"] - stats[1]["ipackets"]
        lost_b = stats[1]["opackets"] - stats[0]["ipackets"]

        total_sent = stats[0]["opackets"] + stats[1]["opackets"]
        total_rcvd = stats[0]["ipackets"] + stats[1]["ipackets"]

        print "\npackets lost from 0 --> 1:   {0} pkts".format(lost_a)
        print "packets lost from 1 --> 0:   {0} pkts".format(lost_b)
        print "rate={0}, totalReceived={1}, totalSent={2}, frameLoss={3}"\
              .format(rate, total_rcvd, total_sent, lost_a+lost_b)

        if (lost_a == 0) and (lost_b == 0):
            passed = True
        else:
            passed = False

    except STLError as e:
        passed = False
        print e

    finally:
        c.disconnect()

def print_help():

    print "args: [-h] -d <duration> -s <size of frame in bytes>"+\
    " [-r] <traffic rate with unit: %, mpps> "+\
    "--p1_src_mac <port1_src_mac> "+\
    "--p1_dst_mac <port1_dst_mac> "+\
    "--p1_src_start_ip <port1_src_start_ip> "+\
    "--p1_src_end_ip <port1_src_end_ip> "+\
    "--p1_dst_start_ip <port1_dst_start_ip> "+\
    "--p1_dst_end_ip <port1_dst_end_ip> "+\
    "--p2_src_mac <port2_src_mac> "+\
    "--p2_dst_mac <port2_dst_mac> "+\
    "--p2_src_start_ip <port2_src_start_ip> "+\
    "--p2_src_end_ip <port2_src_end_ip> "+\
    "--p2_dst_start_ip <port2_dst_start_ip> "+\
    "--p2_dst_end_ip <port2_dst_end_ip>"


def main(argv):

    _duration = 10
    _frame_size = 64
    _rate = '1mpps'
    _traffic_options = {}

    try:
        opts, args = getopt.getopt(argv, "hd:s:r:o:",
                                   ["help",
                                    "p1_src_mac=",
                                    "p1_dst_mac=",
                                    "p1_src_start_ip=",
                                    "p1_src_end_ip=",
                                    "p1_dst_start_ip=",
                                    "p1_dst_end_ip=",
                                    "p2_src_mac=",
                                    "p2_dst_mac=",
                                    "p2_src_start_ip=",
                                    "p2_src_end_ip=",
                                    "p2_dst_start_ip=",
                                    "p2_dst_end_ip="])
    except getopt.GetoptError:
        print_help()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ('-h', "--help"):
            print_help()
            sys.exit()
        elif opt == '-d':
            _duration = int(arg)
        elif opt == '-s':
            _frame_size = int(arg)
        elif opt == '-r':
            _rate = arg
        elif opt.startswith("--p"):
            _traffic_options[opt[2:]] = arg

    print _traffic_options
    if len(_traffic_options) != 6:
        print "Supported only: src_start_ip, src_end_ip, dst_start_ip"
        print_help()
        sys.exit(2)

    pkt_a, pkt_b = create_packets(_traffic_options,
                                  frame_size=_frame_size)

    simple_burst(pkt_a, pkt_b, duration=_duration, rate=_rate)

if __name__ == "__main__":
    main(sys.argv[1:])

