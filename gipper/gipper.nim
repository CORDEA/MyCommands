# Copyright 2016 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

  # http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Yoshihiro Tanaka <contact@cordea.jp>
# date  :2016-08-16

import os, strutils, sequtils

const
  VERSION = "0.1"

when isMainModule:
  var params = commandLineParams()
  params.insert("hub", 0)
  if len(params) > 1:
    let subcmd = params[1]
    # your processes here.
    # if subcmd == "clone":
    #   ...
    if subcmd == "--version" or subcmd == "version":
      echo "gipper version " & VERSION
  params = params.map(proc (x: string): string = "\"" & x & "\"")
  quit execShellCmd(params.join " ")
