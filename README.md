# Table of Contents

- [Alpine Linux Setup](#alpine-linux-setup)
  - [About](#about)
- [Installation](#installation)
  - [Download the File](#download-the-file)
  - [Run the Script](#run-the-script)
- [This is My First Time With Alpine Linux](#this-is-my-first-time-with-alpine-linux)

# Alpine Linux Setup

## About

This is a script to help you set up alpine linux, it does soo many things!!

You can turn on edge release or even download glibc apps, which is not possible by default in alpine linux. Common apps are already included within the setup, but for other apps you want to install but not available in the setup, you can always refer to [distrobox documentation](https://distrobox.it/#distrobox) and the application download page.

Though if you want me to add it to the setup, you can open issues about it.

# Installation

## Download the File

First you need to [setup your alpine](#this-is-my-first-time-with-alpine-linux)

Next you can clone/download it like this

```sh
apk add git
git clone https://github.com/ChrLos/alpine-setup.git
```

## Run the Script

```
cd ./alpine-setup/
./setup.sh
```

If you get ```Please run this script as root or use sudo!```
Then do this instead

```sh
doas ./setup.sh
```

#### All done!! Now what?

Well you can read the setup and select as you need, that's all. It's easy right? Only took seconds.

**Some recommendation :** 

Select everything in the first page of the script (Initial Setup, LxQt, Pipewire, Distrobox)

# This is My First Time With Alpine Linux

Well it's actually simple
- Boot to Alpine Linux OS
- After boot, you can find `localhost login`, type `root`
- Do setup-alpine
  - **Some notes first**

    [enter] → press the enter key

    (username) → type your desired name
    
    (strong password) → type a strong password and remember it
  - **How to do setup-alpine**

    Type this first in the command
    ```
    setup-alpine
    ```

    After enter, you need to fill it. This is how I usually fill it

    ```sh
    us
    us
    [enter]
    [enter]
    [enter]
    [enter]
    123
    123
    [enter]
    [enter]
    [enter]
    [enter]
    (username)
    [enter]
    (strong password)
    (strong password)
    [enter]
    [enter]
    sda
    sys
    y
    ```
- After all done, type `reboot`
- After reboot, you can find `localhost login`, type `root` like before
- Then `password` will pop, just type `123`

Go [download and run the script](#installation) when you're done
