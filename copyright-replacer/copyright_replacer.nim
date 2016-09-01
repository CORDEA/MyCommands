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
# date  :2016-09-01

import os, pegs, strutils, subexes, times

const
  copyright = """'Copyright' \s* \[* {\d+} \]* \s* \[* {\w+ \s* \w+} \]*"""
  temp = "Copyright $# $#"

type
  SyntaxError = object of Exception

proc handleMatches(m: int, n: int, c: openarray[string]): string = 
  if n == 2:
    var arr: array[2, string] = [c[0], c[1]]
    let
      year = parseInt(arr[0])
      currentYear = getLocalTime(getTime()).year
    if year != currentYear:
      arr[0] = subex("$#-$#") % [$year, $currentYear]
    result = subex(temp) % arr
  else:
    raise newException(SyntaxError, "")
    
proc replace(filename: string) =
  var lines = filename.readFile()
  lines = lines.replace(peg(copyright), handleMatches)
  let newfile = filename & "_new"
  let writef = newfile.open(fmWrite)
  writef.write lines
  writef.close()
  newfile.moveFile filename

proc walk(dirname: string) =
  for kind, path in walkDir(dirname):
    if kind == pcFile:
      replace(path)
    if kind == pcDir:
      walk(path)

when isMainModule:
    let arg = commandLineParams()
    if len(arg) == 1:
      if existsFile arg[0]:
        replace(arg[0])
      if existsDir arg[0]:
        walk(arg[0])
