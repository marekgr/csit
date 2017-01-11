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
| Resource | resources/libraries/robot/performance.robot
| Resource | resources/libraries/robot/tagging.robot
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRCHK
| ...        | NIC_Intel-X520-DA2 | L2XCFWD | BASE | DOT1AD
| Suite Setup | 3-node Performance Suite Setup with DUT's NIC model
| ... | L2 | Intel-X520-DA2
| Suite Teardown | 3-node Performance Suite Teardown
| Test Setup | Setup all DUTs before test
| Test Teardown | Run Keywords | Remove startup configuration of VPP from all DUTs
| ...           | AND          | Show vpp trace dump on all DUTs
| Documentation | *Reference NDR throughput L2XC with 802.1ad verify test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 xconnect.
| ... | 802.1ad tagging is applied on link between DUT1 and DUT2 with inner 4B
| ... | vlan tag (id=100) and outer 4B vlan tag (id=200).
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 cross-
| ... | connect. DUT1 and DUT2 tested with 2p10GE NIC X520 Niantic by Intel.
| ... | *[Ver] TG verification:* In short performance tests, TG verifies
| ... | DUTs' throughput at ref-NDR (reference Non Drop Rate) with zero packet
| ... | loss tolerance. Ref-NDR value is periodically updated acording to
| ... | formula: ref-NDR = 0.9x NDR, where NDR is found in RFC2544 long
| ... | performance tests for the same DUT configuration. Test packets are
| ... | generated by TG on links to DUTs. TG traffic profile contains two L3
| ... | flow-groups (flow-group per direction, 253 flows per flow-group) with
| ... | all packets containing Ethernet header, IPv4 header with IP protocol=61
| ... | and static payload. MAC addresses are matching MAC addresses of the
| ... | TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${subid}= | 10
| ${outer_vlan_id}= | 100
| ${inner_vlan_id}= | 200
| ${type_subif}= | two_tags
| ${tag_rewrite}= | pop-2

*** Test Cases ***
| TC01: Verify 64B ref-NDR at 2x 2.9Mpps - DUT L2XC with 802.1ad - 1thread 1core 1rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 64 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 1T1C | STHREAD
| | ${framesize}= | Set Variable | 64
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 2.9mpps
| | Given Add '1' worker threads and rxqueues '1' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Add No Multi Seg to all DUTs
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC02: Verify 1514B ref-NDR at 2x 810.635kpps - DUT L2XC with 802.1ad - 1thread 1core 1rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 1514 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 1T1C | STHREAD
| | ${framesize}= | Set Variable | 1514
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 810635pps
| | Given Add '1' worker threads and rxqueues '1' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Add No Multi Seg to all DUTs
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC03: Verify 9000B ref-NDR at 2x 138.458kpps - DUT L2XC with 802.1ad - 1thread 1core 1rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 1T1C | STHREAD
| | ${framesize}= | Set Variable | 9000
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 138458pps
| | Given Add '1' worker threads and rxqueues '1' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC04: Verify 64B ref-NDR at 2x 7Mpps - DUT L2XC with 802.1ad - 2thread 2core 1rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 2 thread, 2 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 64 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | 64
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 7.0mpps
| | Given Add '2' worker threads and rxqueues '1' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Add No Multi Seg to all DUTs
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC05: Verify 1514B ref-NDR at 2x 810.635kpps - DUT L2XC with 802.1ad - 2thread 2core 1rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 2 thread, 2 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 1514 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | 1514
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 810635pps
| | Given Add '2' worker threads and rxqueues '1' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Add No Multi Seg to all DUTs
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC06: Verify 9000B ref-NDR at 2x 138.458kpps - DUT L2XC with 802.1ad - 2thread 2core 1rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 2 thread, 2 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | 9000
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 138458pps
| | Given Add '2' worker threads and rxqueues '1' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC07: Verify 64B ref-NDR at 2x 8Mpps - DUT L2XC with 802.1ad - 4thread 4core 2rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 4 thread, 4 phy core, \
| | ... | 2 receive queue per NIC port. [Ver] Verify ref-NDR for 64 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | 64
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 8.0mpps
| | Given Add '4' worker threads and rxqueues '2' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Add No Multi Seg to all DUTs
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC08: Verify 1514B ref-NDR at 2x 810.635kpps - DUT L2XC with 802.1ad - 4thread 4core 2rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 4 thread, 4 phy core, \
| | ... | 2 receive queue per NIC port. [Ver] Verify ref-NDR for 1514 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | 1514
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 810635pps
| | Given Add '4' worker threads and rxqueues '2' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Add No Multi Seg to all DUTs
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect

| TC09: Verify 9000B ref-NDR at 2x 138.458kpps - DUT L2XC with 802.1ad - 4thread 4core 2rxq
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC with 802.1ad config with 4 thread, 4 phy core, \
| | ... | 2 receive queue per NIC port. [Ver] Verify ref-NDR for 9000 Byte
| | ... | frames using single trial throughput test.
| | [Tags] | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | 9000
| | ${duration}= | Set Variable | 10
| | ${rate}= | Set Variable | 138458pps
| | Given Add '4' worker threads and rxqueues '2' in 3-node single-link topo
| | And   Add PCI devices to DUTs from 3-node single link topology
| | And   Apply startup configuration on all VPP DUTs
| | And   VPP interfaces in path are up in a 3-node circular topology
| | When VLAN subinterfaces initialized on 3-node topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And L2 tag rewrite method setup on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Interfaces and VLAN sub-interfaces inter-connected using L2-xconnect
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Traffic should pass with no loss | ${duration} | ${rate}
| | ...                                   | ${framesize} | 3-node-xconnect
