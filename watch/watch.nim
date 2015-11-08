import os, osproc
import times, strutils
import parseopt2

proc exec(cmd: string) =
    discard execCmd("clear")

    let (output, err) = execCmdEx(cmd)
    echo(output)

proc loop(cmd: string, n: int) =
    while(true):
        exec(cmd)
        sleep(n * 1000)

when isMainModule:
    var
        cmd: string
        n: int
    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            cmd = key
        of cmdLongOption, cmdShortOption:
            case key
            of "n":
                n = parseInt(val)
        of cmdEnd:
            discard
    if cmd != nil and n != 0:
        loop(cmd, n)
