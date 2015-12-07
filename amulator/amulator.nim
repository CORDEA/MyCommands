discard """
Copyright [2015] [Yoshihiro Tanaka]
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Author: Yoshihiro Tanaka <contact@cordea.jp>
date  : 2015-12-05
"""

import os, osproc
import re
import parseopt2

proc getEmulators():seq[string] =
    var
        arr: seq[string] = @[]
        matches: array[1, string]
    let envName = "HOME"
    if existsEnv envName:
        let home = getEnv envName
        let androidPath = home & "/.android"
        if existsDir androidPath:
            if existsDir androidPath & "/avd":
                for path in walkDirRec(androidPath & "/avd", {pcFile}):
                    if find(path, re"(\w+)\.ini$", matches) >= 0:
                        arr.add matches[0]
    return arr

proc findApi(devices:openarray[string], expect:string):string =
    var matches: array[1, string]
    for device in devices:
        if find(device, re"API_(\d{1,2})", matches) >= 0:
            if matches[0] == expect:
                return device

proc launch(name: string, arch: string, is32bit: bool) =
    let envName = "ANDROID_HOME"
    if existsEnv(envName):
        let home = getEnv(envName)
        echo "found environment variable " & home
        var prog = "/tools/emulator"
        if is32bit:
            prog &= "-"
        else:
            prog &= "64-"
        discard execCmd(home & prog & arch & " @" & name)

when isMainModule:
    var
        arch: string = "x86"
        name: string
        api: string
        is32bit: bool

    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            name = val
        of cmdLongOption, cmdShortOption:
            case key
            of "arch":
                arch = if val == nil: arch else: val
            of "a", "api":
                api = val
            of "32bit":
                is32bit = true
            else: discard
        else: discard
    
    let arr = getEmulators()

    echo("name ", name, " api ", api)
    if name == nil:
        if api != nil:
            name = findApi(arr, api)
            echo("find api: ", (if name == nil: "not found" else: name))
    if name == nil:
        echo "name is nil, quit."
        quit(1)

    launch(name, arch, is32bit)
