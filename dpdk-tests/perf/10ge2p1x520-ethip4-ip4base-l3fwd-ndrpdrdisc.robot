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

*** Settings ***
| Resource | resources/libraries/robot/performance_setup.robot
| Resource | resources/libraries/robot/DPDK/default.robot
| Library | resources.libraries.python.topology.Topology
| Library | resources.libraries.python.NodePath
| Library | resources.libraries.python.InterfaceUtil
| Library | resources.libraries.python.DPDK.DPDKTools
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDRDISC | 1NUMA
| ... | NIC_Intel-X520-DA2 | DPDK | IP4FWD | BASE | ETH
| Suite Setup | Set up DPDK 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X520-DA2
| Suite Teardown | Tear down DPDK 3-node performance topology
| Documentation | *RFC2544: Pkt throughput IPv4 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L3 IPv4 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 run the DPDK l3fwd application
| ... | DUT1 and DUT2 tested with 2p10GE NIC X520 Niantic by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using either binary search or linear search
| ... | algorithms with configured starting rate and final step that determines
| ... | throughput measurement resolution. Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 253 flows per flow-group) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static
| ... | payload. MAC addresses are matching MAC addresses of the TG node
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X520-DA2 bandwidth limit
| ${s_limit} | ${10000000000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-ip4dst253

*** Test Cases ***
| tc01-64B-1t1c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start\
| | ... | at 10GE linerate, step 100kpps.
| | ...
| | [Tags] | 1T1C | STHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '1' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc02-64B-1t1c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start\
| | ... | at 10GE linerate, step 100kpps, LT=0.5%.
| | ...
| | [Tags] | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '1' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc03-1518B-1t1c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start\
| | ... | at 10GE linerate, step 10kpps.
| | ...
| | [Tags] | 1T1C | STHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '1' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc04-1518B-1t1c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start\
| | ... | at 10GE linerate, step 10kpps, LT=0.5%.
| | ...
| | [Tags] | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '1' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc05-9000B-1t1c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start\
| | ... | at 10GE linerate, step 5kpps.
| | ...
| | [Tags] | 1T1C | STHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '1' worker threads and '1' rxqueues with jumbo frames 'yes'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc06-9000B-1t1c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start\
| | ... | at 10GE linerate, step 5kpps, LT=0.5%.
| | ...
| | [Tags] | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '1' worker threads and '1' rxqueues with jumbo frames 'yes'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc07-64B-2t2c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start\
| | ... | at 10GE linerate, step 100kpps.
| | ...
| | [Tags] | 2T2C | MTHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '2' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc08-64B-2t2c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start\
| | ... | at 10GE linerate, step 100kpps, LT=0.5%.
| | ...
| | [Tags] | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '2' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc09-1518B-2t2c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start\
| | ... | at 10GE linerate, step 10kpps.
| | ...
| | [Tags] | 2T2C | MTHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '2' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc10-1518B-2t2c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start\
| | ... | at 10GE linerate, step 10kpps, LT=0.5%.
| | ...
| | [Tags] | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '2' worker threads and '1' rxqueues with jumbo frames 'no'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc11-9000B-2t2c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start\
| | ... | at 10GE linerate, step 5kpps.
| | ...
| | [Tags] | 2T2C | MTHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '2' worker threads and '1' rxqueues with jumbo frames 'yes'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc12-9000B-2t2c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 2 threads, 2 phy cores,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start\
| | ... | at 10GE linerate, step 5kpps, LT=0.5%.
| | ...
| | [Tags] | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '2' worker threads and '1' rxqueues with jumbo frames 'yes'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc13-64B-4t4c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start\
| | ... | at 10GE linerate, step 100kpps.
| | ...
| | [Tags] | 4T4C | MTHREAD | NDRDISC
| | ...
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '4' worker threads and '2' rxqueues with jumbo frames 'no'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc14-64B-4t4c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start\
| | ... | at 10GE linerate, step 100kpps, LT=0.5%.
| | ...
| | [Tags] | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${100000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '4' worker threads and '2' rxqueues with jumbo frames 'no'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc15-1518B-4t4c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start\
| | ... | at 10GE linerate, step 10kpps.
| | ...
| | [Tags] | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '4' worker threads and '2' rxqueues with jumbo frames 'no'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc16-1518B-4t4c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start\
| | ... | at 10GE linerate, step 10kpps, LT=0.5%.
| | ...
| | [Tags] | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '4' worker threads and '2' rxqueues with jumbo frames 'no'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}

| tc17-9000B-4t4c-ethip4-ip4base-l3fwd-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start\
| | ... | at 10GE linerate, step 5kpps.
| | ...
| | [Tags] | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '4' worker threads and '2' rxqueues with jumbo frames 'yes'
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold}

| tc18-9000B-4t4c-ethip4-ip4base-l3fwd-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L3 IPv4 routing config with 4 threads, 4 phy cores,\
| | ... | 2 receive queues per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start\
| | ... | at 10GE linerate, step 5kpps, LT=0.5%.
| | ...
| | [Tags] | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | ...
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Start L3FWD '4' worker threads and '2' rxqueues with jumbo frames 'yes'
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile} | ${min_rate} | ${max_rate}
| | ... | ${threshold} | ${perf_pdr_loss_acceptance}
| | ... | ${perf_pdr_loss_acceptance_type}