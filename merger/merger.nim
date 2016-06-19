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
# date  : 2016-06-19

import os
import strutils, sequtils

proc addLastChar(x: string): string =
    if x[len(x) - 1] == '"':
        if x[len(x) - 2] == ',':
            return x & "\""
    else:
        return x & "\""
    return x

proc readFiles(files: seq[string]): seq[string] =
    let
        cont1 = files[0].readFile().split("\"\n")
        cont2 = files[1].readFile().split("\"\n")
        ded = deduplicate(concat(cont1, cont2))
    result = ded.map(addLastChar)
    
when isMainModule:
    let params = commandLineParams()
    if len(params) != 2:
        stderr.writeLine "Parameter is missing."
        quit 1
    if params[0].fileExists() and params[1].fileExists():
        var uniq = readFiles(params)
        echo uniq.join "\n"
    else:
        stderr.writeLine "Invalid file path."
        quit 1
