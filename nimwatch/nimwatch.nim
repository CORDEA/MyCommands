import os, osproc
import times, strutils
import parseopt2
import threadpool
import math
import ncurses

type
    window = ref winParam
    winParam = object
        x: int
        y: int

proc getScreenSize(): window =
    var
        x, y: int
        win: window
    new(win)
    getmaxyx(initscr(), y, x)
    endwin()
    win.x = x
    win.y = y
    return win

proc getHeader(cmd: string, n: int, x: int): string =
    let date = getLocalTime(getTime())
    let left  = "Every " & $n & "s: " & cmd
    let right = format(date, "ddd',' dd MMM yyyy HH:mm:ss")
    let space = x - (left.len + right.len)
    result = left & " ".repeat(space) & right
    return

proc getOutput(cmd: string): string =
    let (outp, _) = execCmdEx(cmd)
    return outp

proc echo(inp: varargs[string]) =
    var outp = ""
    for s in items(inp):
        if s != nil:
            outp = outp & s
    if outp.len > 0:
        discard execCmd("echo '" & outp & "'")

proc outputToScreen(outp: string, cmd:string, ni: int, win: window) =
    let header = 2
    echo(getHeader(cmd, ni, win.x), "\n")
    var lignes = split(outp, "\n")
    for i, v in lignes:
        if i < (win.y - header) - 1:
            echo(v)

proc exec(cmd: string, n: int, win: window) =
    discard execCmd("clear")
    let output = getOutput(cmd)
    outputToScreen(output, cmd, n, win)

proc asyncExec(cmd: string, ni: int, win: window) =
    let n = float(ni)
    proc onAsyncCompleted(outp: string, cmd: string, bef: float) =
        let bet = toSeconds(getTime()) - bef
        let slpSec = int(math.ceil((n - bet) * 1000))
        if slpSec > 0:
            sleep(slpSec)
        discard execCmd("clear")
        outputToScreen(outp, cmd, ni, win)
        asyncExec(cmd, ni, win)
    let bef = toSeconds(getTime())
    let outp = ^(spawn getOutput(cmd))
    onAsyncCompleted(outp, cmd, bef)

proc loop(cmd: string, n: int, win: window) =
    while true:
        exec(cmd, n, win)
        sleep(n * 1000)

proc loopAsync(cmd: string, n: int, win: window) =
    exec(cmd, n, win)
    asyncExec(cmd, n, win)

when isMainModule:
    var
        cmd: string
        n: int
        async: bool = false
    let win:window = getScreenSize()
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
            loopAsync(cmd, n, win)
        else:
            loop(cmd, n, win)
