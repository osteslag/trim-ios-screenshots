# Trim iOS Screenshots

This Xcode project contains two targets, each offering to integrate the job of trimming the status bar from iOS screenshots:

1. An Automator action, *Trim iOS Screenshots*, and
2. A Foundation command line utility, *trims* (as a subproject).

The command line utility does the actual job of the trimming. It uses multiple threads if applicable to make the execution faster. The action embeds and uses the utility and offers the convenience and flexibility of integrating with Automator workflows.

If you don’t want to do the compiling yourself, head over to the [Releases section](https://github.com/osteslag/trim-ios-screenshots/releases) and download the binaries directly:

![Binaries for Download](https://github.com/osteslag/trim-ios-screenshots/raw/master/Screenshots/downloads.png)

_Important: the binaries are not signed. Download and use at your own risk._


## Installation

Both sets of binaries are self-contained. If you only wish to use one of them, just install that one.

### The `trims` Command

If you’re building the command from source, do so with the *Release* configuration by selecting *Product > Build For > Archiving* in Xcode.

1. Copy `trims` to a directory in your `$PATH`, e.g. `/usr/local/bin/`.
2. Optionally copy the `man` page, `trims.1`, to a path in your `$MANPATH` or `/usr/local/share/man/man1/`. You may have to create the latter.


### The *Trim iOS Screenshots* Action

Depending on whether you’re building the action in Xcode yourself or downloading the compiled bundle, do one of the following:

- Build the *Trim iOS Screenshots* target using the *Release* configuration by selecting *Product > Build For > Archiving*. This will automatically install the action in `~/Library/Automator/`. Or
- Copy the compiled action to `~/Library/Automator/` or `/Library/Automator/` to make it available for the current user only or to all users on the Mac respectively.


## Usage

Before doing any trimming, make sure the screenshots are rotated so that the status bar is at the top edge.

The command line utility is used like this:

    $ trims -r path ...

Where the `-r` option specifies that folder paths should be traversed recursively. Note that input image will be overwritten with the trimmed images.

Learn more about the command by typing any of the following:

    $ trims --help
    $ man trims

The `man` page is also available online [here](https://github.com/osteslag/trim-ios-screenshots/raw/master/Command/README.md).

To use the *Trim iOS Screenshots* action, just add it to your workflow like any other action. It takes image files and folders as input and passes the exact same as output:

![Sample Automator workflow screenshot](https://github.com/osteslag/trim-ios-screenshots/raw/master/Screenshots/workflow.png)

The workflow above takes the Finder selection and trims away the top 20 points (40 pixels on a Retina display) of any encountered image files in the selection that have the dimensions of any known iOS device screen.

Note, that if you generate the screenshots from iOS Simulator, don’t grab the whole window (⇧⌘4). Instead just save the screen using the fairly new menu item *Save Screen* (⌘S).


## License

This project is available under the [BSD 2-Clause “Simplified” License](http://www.opensource.org/licenses/BSD-2-Clause):

Copyright (c) 2012-14, Joachim Bondo <https://github.com/osteslag/>  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
