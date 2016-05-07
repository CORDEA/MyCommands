#!/usr/bin/env python
# encoding:utf-8
#
# Copyright 2015-2016 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

__Author__  =  "Yoshihiro Tanaka"
__date__    =  "2015-01-15"
__version__ =  "0.1.0 (Beta)"

from optparse import OptionParser

def optSettings():
    usage   = "%prog [options] [replace configuration file] [target file]\nDetailed options -h or --help"
    version = __version__
    parser = OptionParser(usage=usage, version=version)

    parser.add_option(
        "-d", "--delimiter",
        action  = "store",
        type    = "str",
        dest    = "delim",
        default = "",
        help    = "Set the delimiter of the replace configuration file."
    )

    return parser.parse_args()

class ReplaceAll:
    def __init__(self, options, args):
        self._DELIM  = options.delim
        self._SOURCE = args[0]
        self._TARGET = args[1]

    def replace(self):
        with open(self._SOURCE) as f:
            if len(self._DELIM) == 0:
                repDict = {line.split()[0]: line.split()[1].rstrip() for line in f}
            else:
                repDict = {line.split(self._DELIM)[0]: line.split(self._DELIM)[1].rstrip() for line in f}

        with open(self._TARGET) as f:
            lines = [r.rstrip() for r in f.readlines()]

        for line in lines:
            for k in repDict.keys():
                if k in line:
                    line = line.replace(k, repDict[k])
            print line

if __name__ == '__main__':
    options, args = optSettings()
    ra = ReplaceAll(options, args)
    ra.replace()
