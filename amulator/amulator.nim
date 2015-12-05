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
import parseopt2

proc launch(name: string, arch: string) =
    let envName = "ANDROID_HOME"
    if existsEnv(envName):
        let home = getEnv(envName)
        echo "found environment variable " & home
        discard execCmd(home & "/emulator64-" & arch & " @" & name)

when isMainModule:
    var
        arch: string
        name: string

    for kind, key, val in getopt():
        case kind
        of cmdLongOption, cmdShortOption:
            case key
            of "a", "arch":
                arch = val
            of "n", "name":
                name = val
            else: discard
        else: discard

    launch(name, arch)
