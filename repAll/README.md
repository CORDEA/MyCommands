#Multiple of replace by python

The repository contains the command to make multiple Replace.

##Features
* read a Replace target from replace configuration file.

##Like this

###Replace configuration file

rep.txt
```
apple	banana
apricot	kiwi fruit
watermelon	melon
grape	orange
```

###Target file

target.txt
```
apricot
watermelon
apple and grape juice
```

###Enter the command

Delimiter "split()" is the default.
```sh
repall -d$'\t' rep.txt target.txt > result.txt
```

###Result

result.txt
```
kiwi fruit
melon
banana and orange juice
```

