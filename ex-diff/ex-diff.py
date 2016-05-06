#!/usr/bin/env python
# encoding:utf-8
#
# Copyright 2014-2016 Yoshihiro Tanaka
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

__Author__  =  "Yoshihiro Tanaka <contact@cordea.jp>"
__date__    =  "2014-11-18"
__version__ =  "0.1.2 (Beta)"

import sys, os, re
from optparse import OptionParser

def optSettings():
    usage   = "%prog [options] [sourcefile] [targetfile]\nDetailed options -h or --help"
    version = __version__
    parser = OptionParser(usage=usage, version=version)

    parser.add_option(
        "-d", "--delimiter",
        action  = "store",
        type    = "str",
        dest    = "delim",
        default = "",
        help    = "Set the delimiter of the source file and target file."
    )

    parser.add_option(
        "--sd", "--source-delimiter",
        action  = "store",
        type    = "str",
        dest    = "sdelim",
        default = "",
        help    = "Set the delimiter of the source file. (priority than delimiter option.)"
    )

    parser.add_option(
        "--td", "--target-delimiter",
        action  = "store",
        type    = "str",
        dest    = "tdelim",
        default = "",
        help    = "Set the delimiter of the target file. (priority than delimiter option.)"
    )

    parser.add_option(
        "-o", "--output-delimiter",
        action  = "store",
        type    = "str",
        dest    = "odelim",
        default = None,
        help    = "Set the delimiter of output. "
    )

    parser.add_option(
        "-f", "--field",
        action  = "store",
        type    = "int",
        dest    = "field",
        default = None,
        help    = "Set the field of the source file and target file. (Start of the index is 0)"
    )

    parser.add_option(
        "--sf", "--source-field",
        action  = "store",
        type    = "int",
        dest    = "sfield",
        default = None,
        help    = "Set the field of the source file. (priority than field option.)"
    )

    parser.add_option(
        "--tf", "--target-field",
        action  = "store",
        type    = "int",
        dest    = "tfield",
        default = None,
        help    = "Set the field of the target file. (priority than field option.)"
    )

    parser.add_option(
        "-u", "--uniq",
        action  = "store_true",
        dest    = "unique",
        default = False,
        help    = "Output fields that do not exist in the target. (Output is stderr.)"
    )

    parser.add_option(
        "-c", "--count",
        action  = "store_true",
        dest    = "count",
        default = False,
        help    = "Display the counting result."
    )

    parser.add_option(
        "--only-key",
        action  = "store_true",
        dest    = "only",
        default = False,
        help    = "Only the output target of the key."
    )

    parser.add_option(
        "--debug",
        action  = "store_true",
        dest    = "debug",
        default = False,
        help    = "Output error messages."
    )

    return parser.parse_args()

class DiffFiles:
    def __init__(self, options, args):
        self._SOURCE   = args[0]
        self.stdin = False
        try:
            self._TARGET = args[1]
        except:
            self._TARGET = args[0]
            self.stdin   = True
        self._DELIM    = options.delim
        self._S_DELIM  = options.sdelim
        self._T_DELIM  = options.tdelim
        self._O_DELIM  = options.odelim
        self._FIELD    = options.field
        self._S_FIELD  = options.sfield
        self._T_FIELD  = options.tfield
        self._UNIQUE   = options.unique
        self._COUNT    = options.count
        self._ONLY     = options.only
        self._DEBUG    = options.debug
    
        if os.path.isdir(self._SOURCE):
            print "error"
        if not self.stdin:
            if os.path.isdir(self._TARGET):
                print "error"

        if self._SOURCE == "-":
            self.stdin = True

        if len(self._DELIM) > 0:
            if len(self._S_DELIM) == 0:
                self._S_DELIM = self._DELIM
            if len(self._T_DELIM) == 0:
                self._T_DELIM = self._DELIM

        if self._FIELD != None:
            if self._S_FIELD == None:
                self._S_FIELD = self._FIELD
            if self._T_FIELD == None:
                self._T_FIELD = self._FIELD
        else:
            if self._S_FIELD == None:
                self._S_FIELD = 0
            if self._T_FIELD == None:
                self._T_FIELD = 0

    def diff(self):
        _SOURCE  = self._SOURCE
        _TARGET  = self._TARGET

        _S_DELIM = self._S_DELIM
        _T_DELIM = self._T_DELIM

        _S_FIELD = self._S_FIELD
        _T_FIELD = self._T_FIELD

        _COUNT   = self._COUNT
        _UNIQUE  = self._UNIQUE
        _DEBUG   = self._DEBUG

        targetDict = {}

        count = [0, 0]

        targetFile = open(_TARGET)
        tline = targetFile.readline()
        while tline:
            targetList = self.splitLine(tline, _T_DELIM)
            try:
                if targetList[_T_FIELD] in targetDict:
                    if _DEBUG:
                        sys.stderr.write("[TARGET FILE] Overlap in the target field.\n")
                else:
                    targetDict[targetList[_T_FIELD]] = tline
            except:
                if _DEBUG:
                    sys.stderr.write("[TARGET FILE] Element is not enough. Or this line can not be split.\n")
            tline = targetFile.readline()

        if self.stdin:
            sourceFile = sys.stdin
        else:
            sourceFile = open(_SOURCE)
        sline = sourceFile.readline()
        while sline:
            sourceList = self.splitLine(sline, _S_DELIM)
            try:
                source = sourceList[_S_FIELD]
            except:
                if _DEBUG:
                    sys.stderr.write("[SOURCE FILE] Element is not enough. Or this line can not be split.\n")
                source = ""
            if source in targetDict:
                targetList = sourceList + self.splitLine(targetDict[source], _T_DELIM)
                self.checkType(sline, targetDict[source], targetList)
                count[0] += 1
            else:
                if len(source) != 0:
                    if _UNIQUE:
                        sys.stderr.write("%s\n" % source)
            count[1] += 1
            sline = sourceFile.readline()

        if _COUNT:
            sys.stdout.write("ok: %d\n" % count[0])
            sys.stdout.write("ng: %d\n" % (count[1] - count[0]))

    def splitLine(self, line, _DELIM):
        if   len(_DELIM) == 0:
            return [str(r) for r in line.rstrip().split()]
        elif "re/" in _DELIM:
            regex = re.split("^re/|/$", _DELIM)[1]
            return [str(r) for r in re.split(regex, line.rstrip())]
        else:
            return [str(r) for r in line.rstrip().split(_DELIM)]

    def checkType(self, sline, tline, output):
        _ONLY    = self._ONLY
        _O_DELIM = self._O_DELIM
        _S_FIELD = self._S_FIELD

        if _ONLY:
            sys.stderr.write("%s\n" % output[_S_FIELD])
        else:
            if _O_DELIM == None:
                self.stdWrite(sline.rstrip() +   " "    + tline.rstrip())
            else:
                self.stdWrite(_O_DELIM.join(output))

    def stdWrite(self, output):
        sys.stdout.write("%s\n" % output)

if __name__ == '__main__':
    options, args = optSettings()
    df = DiffFiles(options, args)
    df.diff()
