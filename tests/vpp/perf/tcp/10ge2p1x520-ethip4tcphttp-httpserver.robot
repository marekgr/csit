# Copyright (c) 2018 Cisco and/or its affiliates.
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

| Library  | resources.tools.wrk.wrk
| Resource | resources/libraries/robot/wrk/wrk_utils.robot
| Resource | resources/libraries/robot/performance/performance_setup.robot
| Resource | resources/libraries/robot/tcp/tcp_setup.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | HTTP | TCP
| ...
| Suite Setup | Set up 3-node performance topology with wrk and DUT's NIC model
| ... | Intel-XL710
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance test with wrk
| ...
| Documentation | *HTTP requests per seconds, connections per seconds and
| ... | throughput measurement.*
| ...
| ... | *[Top] Network Topologies:* TG-DUT-TG 2-node topology
| ... | with single link between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for IPv4 routing.
| ... | *[Cfg] DUT configuration:*
| ... | *[Ver] TG verification:*
| ... | *[Ref] Applicable standard specifications:*

*** Keywords ***
| Measure throughput or rps or cps
| | [Arguments] | ${traffic_profile} | ${wt} | ${rxq} | ${test_type}
| | ...
| | Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | Add PCI devices to DUTs in 3-node single link topology
| | ${duts}= | Get Matches | ${nodes} | DUT*
| | :FOR | ${dut} | IN | @{duts}
| | | Import Library | resources.libraries.python.VppConfigGenerator
| | | ... | WITH NAME | ${dut}
| | | Run keyword | ${dut}.Add TCP preallocated connections | 1000000
| | | Run keyword | ${dut}.Add TCP preallocated half open connections | 1000000
| | | Run keyword | ${dut}.Add session event queue length | 1000000
| | | Run keyword | ${dut}.Add session preallocated sessions | 1000000
| | | Run keyword | ${dut}.Add session v4 session table buckets | 500000
| | | Run keyword | ${dut}.Add session v4 session table memory | 1g
| | | Run keyword | ${dut}.Add session v4 halfopen table buckets | 2500000
| | | Run keyword | ${dut}.Add session v4 halfopen table memory | 3g
| | | Run keyword | ${dut}.Add session local endpoints table buckets | 2500000
| | | Run keyword | ${dut}.Add session local endpoints table memory | 3g
| | Apply startup configuration on all VPP DUTs
| | Set up HTTP server on the VPP node | 192.168.10.2 | 24
| | Run Keyword If | '${test_type}' == 'bw'
| | ... | Measure throughput | ${traffic_profile}
| | ... | ELSE IF | '${test_type}' == 'rps'
| | ... | Measure requests per second | ${traffic_profile}
| | ... | ELSE IF | '${test_type}' == 'cps'
| | ... | Measure connections per second | ${traffic_profile}

*** Test Cases ***
| tc01-1t1c-ethip4tcphttp-httpserver-cps
| | [Documentation]
| | ... | Measure number of connections per second using wrk.
| | ...
| | [Tags] | 1T1C | TCP_CPS
| | ...
| | [Template] | Measure throughput or rps or cps
| | traffic_profile=wrk-sf-2n-ethip4tcphttp-1u1c1con-cps | wt=1 | rxq=1
| | ... | test_type=cps

| tc02-2t2c-ethip4tcphttp-httpserver-cps
| | [Documentation]
| | ... | Measure number of connections per second using wrk.
| | ...
| | [Tags] | 2T2C | TCP_CPS
| | ...
| | [Template] | Measure throughput or rps or cps
| | traffic_profile=wrk-sf-2n-ethip4tcphttp-1u1c1con-cps | wt=2 | rxq=1
| | ... | test_type=cps

| tc03-4t4c-ethip4tcphttp-httpserver-cps
| | [Documentation]
| | ... | Measure number of connections per second using wrk.
| | ...
| | [Tags] | 4T4C | TCP_CPS
| | ...
| | [Template] | Measure throughput or rps or cps
| | traffic_profile=wrk-sf-2n-ethip4tcphttp-1u1c1con-cps | wt=4 | rxq=2
| | ... | test_type=cps

| tc04-1t1c-ethip4tcphttp-httpserver-rps
| | [Documentation]
| | ... | Measure and report number of requests per second using wrk.
| | ...
| | [Tags] | 1T1C | TCP_RPS
| | ...
| | [Template] | Measure throughput or rps or cps
| | traffic_profile=wrk-sf-2n-ethip4tcphttp-1u1c50con-rps | wt=1 | rxq=1
| | ... | test_type=rps

| tc05-2t2c-ethip4tcphttp-httpserver-rps
| | [Documentation]
| | ... | Measure and report number of requests per second using wrk.
| | ...
| | [Tags] | 2T2C | TCP_RPS
| | ...
| | [Template] | Measure throughput or rps or cps
| | traffic_profile=wrk-sf-2n-ethip4tcphttp-1u1c50con-rps | wt=2 | rxq=1
| | ... | test_type=rps

| tc06-4t4c-ethip4tcphttp-httpserver-rps
| | [Documentation]
| | ... | Measure and report number of requests per second using wrk.
| | ...
| | [Tags] | 4T4C | TCP_RPS
| | ...
| | [Template] | Measure throughput or rps or cps
| | traffic_profile=wrk-sf-2n-ethip4tcphttp-1u1c50con-rps | wt=4 | rxq=2
| | ... | test_type=rps