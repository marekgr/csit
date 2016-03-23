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
| Variables | resources/libraries/python/topology.py
| Library | resources.libraries.python.topology.Topology
| Library | resources.libraries.python.DUTSetup
| Library | resources.libraries.python.TGSetup
| Library | Collections

*** Keywords ***
| Setup all DUTs before test
| | [Documentation] | Setup all DUTs in topology before test execution
| | Setup All DUTs | ${nodes}

| Setup all TGs before traffic script
| | [Documentation] | Prepare all TGs before traffic scripts execution
| | All TGs Set Interface Default Driver | ${nodes}

| Show statistics on all DUTs
| | [Documentation] | Show VPP statistics on all DUTs after the test failed
| | Sleep | 10 | Waiting for statistics to be collected
| | ${duts}= | Get Matches | ${nodes} | DUT*
| | :FOR | ${dut} | IN | @{duts}
| | | Vpp show stats | ${nodes['${dut}']}
