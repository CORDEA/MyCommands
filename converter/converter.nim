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
import strutils

proc getParsedString(parsed: seq[string], idx: int): string =
    return if len(parsed) > idx: "\"" & parsed[idx] & "\"" else: "\"\""

proc convert(filename: string): seq[string] =
    let file = filename.readFile()
    var
        parsed: seq[string]
        r: seq[string]
    result = @[]
    result.add "\"name\",\"url\",\"username\",\"password\",\"extra\""
    for line in file.split("\"\n"):
        let conts = line.split("\",\"")
        parsed = @[]
        for cont in conts:
            var c = cont
            if len(c) > 1:
                if c[0] == '"':
                    c = c[1..len(c) - 1]
                if c[len(c) - 1] == '"':
                    c = c[0..len(c) - 2]
            if len(c) == 1 and c[0] == '"':
                c = ""
            parsed.add c
        r = @[]
        for i in 0..4:
            r.add getParsedString(parsed, i)
        result.add r.join ","

when isMainModule:
    let params = commandLineParams()
    if len(params) != 1:
        stderr.writeLine ""
        quit 1
    if params[0].fileExists():
        echo convert(params[0]).join "\n"
    else:
        stderr.writeLine ""
        quit 1
