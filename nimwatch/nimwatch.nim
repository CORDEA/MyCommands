import os, osproc
import times, strutils
import parseopt2
import threadpool
import math

proc getHeader(cmd: string, n: int): string =
    return "Every " & $n & "s: " & cmd

proc getOutput(cmd: string): string =
    let (outp, _) = execCmdEx(cmd)
    return outp

proc exec(cmd: string, n: int) =
    discard execCmd("clear")
    let output = getOutput(cmd)
    echo(getHeader(cmd, n), "\t", getLocalTime(getTime()), "\n")
    echo(output)

proc asyncExec(cmd: string, ni: int) =
    let n = float(ni)
    proc onAsyncCompleted(outp: string, cmd: string, bef: float) =
        let bet = toSeconds(getTime()) - bef
        sleep(int(math.ceil((n - bet) * 1000)))
        discard execCmd("clear")
        echo(getHeader(cmd, ni), "\t", getLocalTime(getTime()), "\n")
        echo(outp)
        asyncExec(cmd, ni)
    let bef = toSeconds(getTime())
    let outp = ^(spawn getOutput(cmd))
    onAsyncCompleted(outp, cmd, bef)

proc loop(cmd: string, n: int) =
    while(true):
        exec(cmd, n)
        sleep(n * 1000)

proc loopAsync(cmd: string, n: int) =
    exec(cmd, n)
    asyncExec(cmd, n)

when isMainModule:
    var
        cmd: string
        n: int
        async: bool = false
    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            cmd = key
        of cmdLongOption, cmdShortOption:
            case key
            of "n":
                n = parseInt(val)
            of "async":
                async = true
            else: discard
        of cmdEnd:
            discard
    if cmd != nil and n != 0:
        if async:
            loopAsync(cmd, n)
        else:
            loop(cmd, n)

