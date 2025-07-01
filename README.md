# What This Is
The wonderful [Ghostty](https://ghostty.org/) terminal emulator
includes a `pkg` directory where Mitchell H. has filled it with great
high-quality zig packages for a variety of foundational libraries for
graphics and text handling.

I now have multiple Zig projects that use a subset of these packages.
I didn't really like just copying `pkg` out of Ghostty into them:

- It violated my (at least aspirational) goal of "why use two when one
will do".
- I found myself wanting to merge two different (albeit small) additions

So I made an attempt to pull out `pkg` from Ghostty into a stand-alone repository.
This seems worth sharing as I understand Mitchell H. to not be interested in
reviewing, maintaining, etc. additions not strictly beneficial to Ghostty. (Seems
sensible to me.)

# How To Use
Presumably this is obvious to everybody who is learned in `git` and Zig but
noted if only to help me remember.

- clone this somewhere convenient and refer to it with references in the `build.zig.zon` file.  I.e. this fragment from
a `build.zig.zon`

	```zig
        .macos = .{
            .path = "../../ghostpkg/macos",
        },
        .apple_sdk = .{ .path = "../../ghostpkg/apple-sdk" },
	```

- check this into your existing project with `git-subtree`. (`git-subtree` nerd-sniped me while preparing
this repo because it showed up in a web search for "how do I make a subtree of a git project"). In
a clean repository:

	```bash
git subtree add --prefix=. --squash https://github.com/rjkroege/ghostpkg.git
	```

- check into your existing project with however `git-submodule` does it. 😊

# Internal Notes
Note to self: internal documentation for maintaining this repo in [[OrganizingZigMacOSFramework]] and
[[GitSubtreeProjectBestPractices]].


The original README from Ghostty `pkg` that continues to apply:

>  # Packages
>  
>  This folder contains packages written for and used by Ghostty that could
>  potentially be useful for other projects. These are in-tree with Ghostty
>  because I don't want to maintain them as separate projects (i.e. get
>  dedicated issues, PRs, etc.). If you want to use them, you can copy and
>  paste them into your project.
>  
>  ## License
>  
>  **This license only applies to the contents of the `pkg` folder within
>  the Ghostty project. This license does not apply to the rest of the
>  Ghostty project.**
>  
>  Copyright © 2024 Mitchell Hashimoto, Ghostty contributors
>  
>  Permission is hereby granted, free of charge, to any person obtaining a copy of
>  this software and associated documentation files (the “Software”), to deal in
>  the Software without restriction, including without limitation the rights to
>  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
>  of the Software, and to permit persons to whom the Software is furnished to do
>  so, subject to the following conditions:
>  
>  The above copyright notice and this permission notice shall be included in all
>  copies or substantial portions of the Software.
>  
>  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
