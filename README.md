# libgosay_template

**This is a library of Cowsay and Ponysay template, converted to libgosay usable template.**

## Build
The main script `toGoSay.sh` is pretty simple.   
run `./toGoSay.sh` for build every thing or `./toGoSay.sh <module name>`   
"Module" name are :
- "cowsay"
- "cowmore"
- "ponysay"

You can make a PR for enlarging support
Or open an "issue" if you find ... issue

## Make a PR
Easy peasy ...
- Add entry named like `build_*` on `case` section at the bottom    
- Make your `build_*` function, there call the main function `builder`. He took 5 args
    - The converter function name like `from_*`
    - The output folder name
    - The git repository url
    - The path into repository
    - The file extention
- Make your `from_*` converter function

> Et voila !

## Lib GoSay
libgosay is a easy to use, Cowsay reimplementation in Go library !   

you can find it
- On official repo https://git.iglou.eu/Production/libgosay
- Or on Github https://github.com/IGLOU-EU/libgosay