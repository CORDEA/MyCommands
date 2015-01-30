#!/bin/bash
#
# Copyright [2015] [Yoshihiro Tanaka]
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
#
# Author: Yoshihiro Tanaka
# date: 2015-01-30

filename=$1
comment=$2

# check arguments
if [ -z $filename ]; then
    echo "please specify the file name."
    exit 1
fi

# beginning of the comments
if [ -z $comment ]; then
    # default
    comment='#'
else
    if [ ${#comment} -gt 1 ]; then
        echo "comment should be specified in one character."
        exit 1
    fi
fi

for line in `cat $filename`; do
    # run a bash command
    eval `echo $line | cut -d $comment -f 2`
done
