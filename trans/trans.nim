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
# date  :2016-03-08

import oauth/src/oauth2
import os, times
import httpclient
import strutils, parseopt2
import subexes, cgi, json

proc getAccessToken(): string =
    const 
        url = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
        tokenFile = "tokens.txt"
        credFile = "credentials.txt"
        credDir = ".trans/"

    let
        home = getEnv("HOME")
        credPath = home / credDir / credFile
        tokenPath = home / credDir / tokenFile

    var
        needRefresh = false
        token: string

    if tokenPath.fileExists():
        let
            text = tokenPath.readFile()
            texts = text.strip().split(",")
            epoch = parseFloat(texts[0])
            expiresIn = parseFloat(texts[1])
            now = epochTime()

        token = texts[2]
        if (now - epoch) >= expiresIn:
            needRefresh = true
    else:
        needRefresh = true

    if needRefresh:
        let
            cred = credPath.readFile()
            creds = cred.strip().split(",")
            scope = [ "http://api.microsofttranslator.com" ]
            response = clientCredsGrant(url, creds[0], creds[1], scope, false)
            obj = parseJson(response.body)

        if obj.hasKey("expires_in") and obj.hasKey("access_token"):
            let
                expiresIn = obj["expires_in"].str
                epochTime = epochTime()
            token = obj["access_token"].str
            tokenPath.writeFile([$epochTime, expiresIn, token].join ",")
        else:
            echo "access token failed to get. response: " & response.body
            quit 1

    return token 

proc trans(token, text, frm, to: string): string =
    var
        url = "http://api.microsofttranslator.com/V2/Http.svc/Translate"
    url = url & "?text=$#&to=$#&from=$#" % [ encodeUrl(text), encodeUrl(to), encodeUrl(frm) ]

    let r = bearerRequest(url, token)
    return r.body

when isMainModule:
    var
        text: string
        frm: string
        to: string

    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            text = key
        of cmdLongOption, cmdShortOption:
            case key
            of "f", "from":
                frm = val
            of "t", "to":
                to = val
            else: discard
        else: discard

    if text == nil:
        quit 1
    else:
        if frm == nil:
            frm = "ja"
        if to == nil:
            to = "en"
        let token = getAccessToken()
        echo trans(token, text, frm, to)
