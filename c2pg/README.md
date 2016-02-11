# From comments to commands by bash

The repository contains the command to run the command of comments.

##Usage

First argument : input file name

Second argument: comment character

```bash
% ./c2pg.sh hoge.txt "#"
```

###If you use as a command(for Mac)

```bash
% mv c2pg.sh /path/to/dir/c2pg
% chown root:wheel /path/to/dir/c2pg # for Mac
% chmod 755 /path/to/dir/c2pg
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
% ./c2pg.sh test.txt
README.md       c2pg.sh        test.txt
/path/to/dir/myCommands/c2pg
./c2pg.sh: line 41: aaa: command not found
```
