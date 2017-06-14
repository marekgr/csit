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
| Library | resources.libraries.python.Cop
| Library | resources.libraries.python.IPv4Setup.Dut | ${nodes['DUT1']}
| ... | WITH NAME | dut1_v4
| Library | resources.libraries.python.IPv4Setup.Dut | ${nodes['DUT2']}
| ... | WITH NAME | dut2_v4
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRCHK
| ... | NIC_Intel-X520-DA2 | ETH | IP4FWD | FEATURE | COPWHLIST
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance ndrchk test
| ...
| Documentation | *Reference NDR throughput IPv4 whitelist verify test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for IPv4 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv4
| ... | routing, two static IPv4 /24 routes and IPv4 COP security whitelist
| ... | ingress /24 filter entries applied on links TG - DUT1 and DUT2 - TG.
| ... | DUT1 and DUT2 tested with 2p10GE NIC X520 Niantic by Intel.
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
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-ip4src253

*** Test Cases ***
| tc01-64B-1t1c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 64 Byte frames using single trial throughput test
| | ... | at 2x 4.1mpps.
| | [Tags] | 64B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${64}
| | ${rate}= | Set Variable | 4.1mpps
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc02-1518B-1t1c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 1518 Byte frames using single trial throughput test
| | ... | at 2x 812743pps.
| | [Tags] | 1518B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 812743pps
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc03-9000B-1t1c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 9000 Byte frames using single trial throughput test
| | ... | at 2x 138580pps.
| | [Tags] | 9000B | 1T1C | STHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 138580pps
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc04-64B-2t2c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 64 Byte frames using single trial throughput test
| | ... | at 2x 7.2mpps.
| | [Tags] | 64B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${64}
| | ${rate}= | Set Variable | 7.2mpps
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc05-1518B-2t2c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 1518 Byte frames using single trial throughput test
| | ... | at 2x 812743pps.
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 812743pps
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc06-9000B-2t2c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 9000 Byte frames using single trial throughput test
| | ... | at 2x 138580pps.
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 138580pps
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc07-64B-4t4c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 4 thread, 4 phy core, 2 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 64 Byte frames using single trial throughput test
| | ... | at 2x 10.4mpps.
| | [Tags] | 64B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${64}
| | ${rate}= | Set Variable | 10.4mpps
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc08-1518B-4t4c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 4 thread, 4 phy core, 2 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 1518 Byte frames using single trial throughput test
| | ... | at 2x 812743pps.
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${1518}
| | ${rate}= | Set Variable | 812743pps
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}

| tc09-9000B-4t4c-ethip4-ip4base-copwhtlistbase-ndrchk
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing and whitelist filters config with \
| | ... | 4 thread, 4 phy core, 2 receive queue per NIC port. [Ver] Verify
| | ... | ref-NDR for 9000 Byte frames using single trial throughput test
| | ... | at 2x 138580pps.
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ${framesize}= | Set Variable | ${9000}
| | ${rate}= | Set Variable | 138580pps
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in 3-node circular topology
| | And Add fib table | ${dut1} | 10.10.10.0 | 24 | 1 | local
| | And Add fib table | ${dut2} | 20.20.20.0 | 24 | 1 | local
| | And COP Add whitelist Entry | ${dut1} | ${dut1_if1} | ip4 | 1
| | And COP Add whitelist Entry | ${dut2} | ${dut2_if2} | ip4 | 1
| | And COP interface enable or disable | ${dut1} | ${dut1_if1} | enable
| | And COP interface enable or disable | ${dut2} | ${dut2_if2} | enable
| | Then Traffic should pass with no loss | ${perf_trial_duration} | ${rate}
| | ... | ${framesize} | ${traffic_profile}
