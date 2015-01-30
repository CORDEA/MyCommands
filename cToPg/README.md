# From comments to commands by bash

The repository contains the command to run the command of comments.

##Usage

First argument : input file name

Second argument: comment character

```bash
% ./ctopg.sh hoge.txt "#"
```

###If you use as a command(for Mac)

```bash
% mv ctopg.sh /path/to/dir/ctopg
% chown root:wheel /path/to/dir/ctopg # for Mac
% chmod 755 /path/to/dir/ctopg
```

##Like this

test.txt

```
# ls
# pwd
# aaa
```

run

```bash
% ./ctopg.sh test.txt
README.md       ctopg.sh        test.txt
/path/to/dir/myCommands/cToPg
./ctopg.sh: line 41: aaa: command not found
```
