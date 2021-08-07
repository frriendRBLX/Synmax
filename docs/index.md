<div align="center"><img src="https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/f/f/2/ff2d728091d013d3768b54e642a0f52677749bfd.png"></img></div>

# Synmax
A Powerful, Light and Quick Modular Command Line for Studio.

<div align="center"><img src="https://s6.gifyu.com/images/Module-method.gif"></img></div>

___

## Why Synmax?

- Fully Modular
    - Synmax is completely module based. This means that you can create a shortcut for virtually anything.

- Fast
    - Using Synmax is very fast. It initalizes all methods within your module upon reloading allowing you to press <kbd>TAB</kbd> to automatically complete a typed command.

- Familar
    - Synmax's design takes inspiration from Mac-OS's Spotlight Search.

- Open Source  
    - Synmax is fully open source, allowing you to fork and modify to suit your needs as a developer. I ask that I am credited for any forked releases.

___

## How do i use it?

<br>

Its Easy! Simply open up synmax and type `mods`, hit <kbd>SPACE</kbd>, then hit <kbd>RETURN</kbd>. This will show a window with every modules name within.

In order to get started using a module, type its `name` and hit <kbd>SPACE</kbd>. Doing so will show contextual information detailing what this module does.

<br>

**Example:**

<kbd>Input:</kbd>
```
module
``` 
<kbd>Contextual Info (displayed below):</kbd>
```
> Module <load|unload|run|peek>
```

<br>

You can further dive into these arguments by hitting <kbd>SPACE</kbd>, then typing the desired argument.

Lets try doing `module load`. This will show us further arguments within `load`.

<br>

**Example:**

<kbd>Input:</kbd>
```
module load 
``` 
<kbd>Contextual Info (displayed below):</kbd>
```
-> Module Load <selected|bypath>
```

<br>

Methods are where the real power of synmax becomes evident. Lets try typing <kbd>SPACE</kbd> and typing `selected`

Our input should be `module load selected`, causing us to reach a method. This method will show contextual information about what it will do when ran.

<br>

**Example:**

<kbd>Input:</kbd>
```
module load bypath <path>

``` 
<kbd>Contextual Info (displayed below):</kbd>
```
-> Load Selected Module by Path (Path)
```

<br>

As we can see, when we type `module load bypath` then hit <kbd>SPACE</kbd>, we see a place for arguments. Each argument is seperated by spaces and will be automatically passed to the function upon pressing <kbd>RETURN</kbd>.

In this case, we will pass through `Workspace.MyModule` to give our fictional ModuleScript to the module. This module in particular doesn't require you to type game first.

<br>

**Example:**

<kbd>Input:</kbd>
```
module load bypath Workspace.MyModule
``` 
<kbd>Contextual Info (displayed below):</kbd>
```
-> Load Selected Module by Path ()
```

<br>

Press <kbd>RETURN</kbd> and voila! You have successfully ran your first command in synamx.

___

## How do i create a module?

You can grab a copy of the module template [here](https://github.com/frriendRBLX/Synmax/blob/master/src/template.lua). This will walk you through creating your own module for use with Synmax.

---

<br>

Happy Developing!

<br>

## Contact

<kbd>Twitter:</kbd>
[@frriendroblox](https://twitter.com/frriendRoblox)

<kbd>My Discord Server:</kbd>
[frriend's Development Hub](www.discord.gg/dmpwZhbq5n)

