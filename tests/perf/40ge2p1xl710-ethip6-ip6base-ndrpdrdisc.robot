# Copyright (c) 2017 Cisco and/or its affiliates.
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

*** Settings ***
| Resource | resources/libraries/robot/performance_setup.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDRDISC
| ... | NIC_Intel-XL710 | ETH | IP6FWD | BASE
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-XL710
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance discovery test | ${min_rate}pps
| ... | ${framesize} | ${traffic_profile}
| ...
| Documentation | *RFC2544: Pkt throughput IPv6 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv6
| ... | routing and two static IPv6 /64 route entries. DUT1 and DUT2 tested with
| ... | 2p40GE NIC XL710 by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using either binary search or linear search
| ... | algorithms with configured starting rate and final step that determines
| ... | throughput measurement resolution. Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 253 flows per flow-group) with all packets
| ... | containing Ethernet header, IPv6 header and static payload.
| ... | MAC addresses are matching MAC addresses of the TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# XL710-DA2 bandwidth limit ~49Gbps/2=24.5Gbps
| ${s_24.5G} | ${24500000000}
# XL710-DA2 Mpps limit 37.5Mpps/2=18.75Mpps
| ${s_18.75Mpps} | ${18750000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip6-ip6src253

*** Test Cases ***
| tc01-78B-1t1c-ethip6-ip6base-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 78 Byte frames
| | ... | using binary search start at 18.75Mpps rate, step 100kpps.
| | [Tags] | 78B | 1T1C | STHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${78}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Set Variable | ${s_18.75Mpps}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc03-1518B-1t1c-ethip6-ip6base-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 1518 Byte frames
| | ... | using binary search start at 24.5G rate, step 10kpps.
| | [Tags] | 1518B | 1T1C | STHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_24.5G} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc07-78B-2t2c-ethip6-ip6base-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 78 Byte frames
| | ... | using binary search start at 18.75Mpps rate, step 100kpps.
| | [Tags] | 78B | 2T2C | MTHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${78}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Set Variable | ${s_18.75Mpps}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc09-1518B-2t2c-ethip6-ip6base-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 1518 Byte frames
| | ... | using binary search start at 24.5G rate, step 10kpps.
| | [Tags] | 1518B | 2T2C | MTHREAD | NDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_24.5G} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc13-78B-4t4c-ethip6-ip6base-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find NDR for 78 Byte frames
| | ... | using binary search start at 18.75Mpps rate, step 100kpps.
| | [Tags] | 78B | 4T4C | MTHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${78}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Set Variable | ${s_18.75Mpps}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc15-1518B-4t4c-ethip6-ip6base-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find NDR for 1518 Byte frames
| | ... | using binary search start at 24.5G rate, step 10kpps.
| | [Tags] | 1518B | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_24.5G} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 3-node circular topology
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
