# Nim Website Creator

A quick website tool. Run the nim file and access your webpage. Website: [https://nimwc.org](https://nimwc.org)

<img src="private/screenshots/NimWC_logo_shadow.png" style="max-height: 250px; display: block;" />

![](https://img.shields.io/github/languages/top/ThomasTJdev/nim_websitecreator?style=for-the-badge) 
![](https://img.shields.io/github/stars/ThomasTJdev/nim_websitecreator?style=for-the-badge)
![](https://img.shields.io/github/languages/code-size/ThomasTJdev/nim_websitecreator?style=for-the-badge) 


# Features

* Blog with custom meta-information and URL's
* Security - 2FA, Firejail, reCAPTCHA
* Fully customizable - log viewer, custom JS & CSS
* Plugins with many features

**See more in FEATURES.md**


# Requirements

To get started you only need:

- Nim >= `1.6.14` (tested with +`2.0`)

Optional dependencies (disabled by default):

- webp (`libwebp`) (only required when using [WebP](https://github.com/juancarlospaco/nim-webp-tools))
- firejail >= `0.9.58` (only required when using [Firejail](https://github.com/juancarlospaco/nim-firejail))
- Xvfb (`xorg-server-xvfb`, required by firejail setting `noX=`)
- **When using Firejail and enabling/disabling a plugin a manual full restart of NimWC is required.** It is therefore not advised to enable/disable plugins in the browser when using Firejail.


# Install

## Install Nim

To compile and install you need [Nim](https://nim-lang.org/). You can easily install Nim using [choosenim](https://nim-lang.org/install_unix.html) with:

```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

## Install NimWC

You only need to perform 1a **or** 1b  **or** 1c - not both of them.


### 1a) Install with Nimble

<details>
If you are using [Nimble](https://github.com/nim-lang/nimble) an executable will be generated and symlinked to `nimwc`, which then can be executed anywhere on your system.

```bash
# Install nimwc with nimble
nimble install nimwc

# Edit the config.cfg accordingly
# (change the confg.cfg path to your nimble folder and the correct package version)
nano ~/.nimble/pkgs/nimwc-[PACKAGE-VERSION]/config/config.cfg

# Run nimwc
# (to add an Admin append the arg "newadmin": nimwc --newadmin)
# (to include some standard pages: nimwc --insertdata)
nimwc

# Login
127.0.0.1:7000/login
```
</details>


### 1b) Compile

<details>

This will generate the executable in the folder.

```bash
# Clone the repository
git clone https://github.com/ThomasTJdev/nim_websitecreator
cd nim_websitecreator

# Generate and edit the config.cfg accordingly
cp config/config_default.cfg config/config.cfg
nano config/config.cfg

# Compile
nimble -d:release build

# Run nimwc
# (to add an Admin append the arg "newadmin": nimwc --newadmin)
# (to include some standard pages: nimwc --insertdata)
./nimwc

# Login
127.0.0.1:7000/login
```

</details>


### 1c) Curl

This will guide you through the installation.

```
curl https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/devops/autoinstall.sh -sSf | sh
# OR
curl https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/devops/autoinstall.sh -sSfLO && echo "6cc7510305db7b0ae5e3755137e71c23c7e08829264ddfb82702e6cac297f1063b46c48c01eafb16156c27a53aa23d1737c34f354ae1834c8498f5bd64b81b3c autoinstall.sh" | sha512sum -c - && sh ./autoinstall.sh
```


# Use

## Arguments

These arguments should be prepended to executable file, e.g. `./nimwc cdata`

* `--showconfig` = Show parsed INI configuration and compile options.
* `--newadmin` = Add the Admin user.
* `--gitupdate` = Updates and force a hard reset.
* `--initplugin` = Create plugin skeleton inside tmp/.
* `--vacuumdb` = Vacuum database and continue (database maintenance).
* `--backupdb` = Compressed full backup of database.
* `--backupdb-gpg` = Compressed signed full backup of database.
* `--newdb` = Generates the database with standard tables (does **not** override or delete tables). `newdb` will be initialized automatic, if no database exists.
* `--insertdata` = Insert standard data, e.g `--insertdata bulma` (this will override existing data)
  * `bulma` = Use Bulma CSS, No JS required (official design) [Default official theme]
  * `bootstrap` = Use Bootstrap and jQuery
  * `water` = Water CSS framework, No JS, HTML Classless (No classes on HTML required)


## Compile options:

These options are only available at compiletime:

* `-d:rc` = Recompile. NimWC is using a launcher, it is therefore needed to force a recompile.
* `-d:adminnotify` = Send error logs (ERROR) to the specified admin email.
* `-d:dev` = Development.
* `-d:devemailon` = Send email when `-d:dev` is activated.
* `-d:demo` = Used on public test site [Nim Website Creator](https://nimwc.org). This option will override the database every 1 hour with the standard data.
* `-d:gitupdate` = Updates directly from Git and force a hard reset.
* `-d:postgres` = Use Postgres database instead of SQLite.
* `-d:packedjson` = Use [PackedJSON](https://github.com/Araq/packedjson#packedjson) instead of [std lib JSON](https://nim-lang.github.io/Nim/json.html). Performance optimization.


# User profiles

There are 3 main user profiles:
* User
* Moderator
* Admin

The access rights below applies to main program. Plugins can have their own definition of user rights.

<details>

## User

The "User" can login and see private pages and blog pages. This user has no access to adding or editing anything.

## Moderator

The "Moderator" can login and see private pages and blog pages. The user **can** add and delete users, but cannot delete or add "Admin" users. The user **cannot** edit JS, CSS and core HTML - only within the pages and blogposts.

## Admin

The "Admin" has access to anything.

</details>

# Blog

You can easily add and edit blogpages. The blogpages support metadata: meta description and meta keywords. It is also possible to specify a category and tags.

<details>

## Blog sorting

In the settings menu you can specify how your blogposts should be sorted, e.g. on modfied date in ascending order.

## Blog searching

To only show blogpost with a specific name, tag or category, you have to append the criteria to the URL. It is not possible to combine these.

```
website.com/blog?name=nim
website.com/blog?category=article
website.com/blog?tags=code
```

</details>

# Plugins

Multiple plugins are available. You can download them within the program at `<webpage>/plugins/repo`.

The plugin repository are located here: [NimWC plugin repository](https://github.com/ThomasTJdev/nimwc_plugins)


# Shortcuts

When editing a blogpage or a normal page press Ctrl+S to save.


# DevOps

<details>
  <summary>Docker, Vagrant, SystemD Service, NGNIX, Admin stuff, etc</summary>

**Docker**

- [Use the Dockerfile](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/devops/docker/) as starting point for your NimWC containers.
- You can run the build_docker.sh and run_docker.sh scripts without changing anything to try out nimwc.


**Vagrant**

- [Use the Vagrantfile](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/devops/Vagrantfile) as starting point for your NimWC VMs.


**NGNIX Config**

- [Use the NGNIX Config file](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/devops/config_nginx_default.cfg) as starting point for your NGNIX Server configuration.


**Google reCAPTCHA**

To activate Google reCAPTCHA [claim you site and server key](https://www.google.com/recaptcha/admin) and insert them into `config.cfg`.


**SystemD**

- [Use the SystemD Service file](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/devops/nimwc.service) as starting point for your NimWC SystemD Services.

Copy the file `nimwc.service` into `/lib/systemd/system/`

```
sudo nano /lib/systemd/system/nimwc.service
```

Enable auto start of NimWC:

```
sudo systemctl enable nimwc
sudo systemctl start nimwc
sudo systemctl status nimwc
```


**CI Builds**

- [YAML Build templates for several Linux Distros (SourceHut).](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/sourcehut#whats-this)


**CrossCompiling, Build for old Linux**

Sometimes you may need Build for very very old Linux, like old Centos and Debian Old Stable,
from a recent Linux, like new Arch or Ubuntu,
heres how you can do it, without a virtual machine with an old Linux to build.

- https://github.com/wheybags/glibc_version_header#glibc-version-header-generator
- https://github.com/phusion/holy-build-box#system-for-building-cross-distribution-linux-binaries
- https://github.com/dockcross/dockcross#dockcross

</details>


# How to Firejail

Optional dependency.

<details>

- Default settings will work Ok on most systems, sane defaults.
- Some settings are kind of technical, you should know some Linux Kernel related stuff.
- Links are provided on the Firejail config page when makes sense.
- You can harden your system even more by tweaking the Firejail config.
- You can always come back to the default settings and it will work Ok.
- Check that Firejail Status at bottom of the page is mostly green.

You can choose how much CPU & RAM NimWC can use,
Firejail will make NimWC believe that theres less CPU & RAM that the actually physically available.
If you choose too small resources for too big load,
then it will feel like when you try to run a heavy program on a VirtualBox with too small CPU & RAM,
but will still run, or do the best to try to run.
This can be useful for Clouds that charge you extra when you pass certain threshold of CPU & RAM usage.

NimWC does not depend on any Hardware device to run, like audio, video, USB, DVD, etc,
so you can block the access to the hardware peripehals,
that also blocks its hardware drivers and libraries that may have vulnerabilities, making your NimWC more secure.

There are options to block root user and the rest of the users on the Linux system,
thats help protect your NimWC against Privilege Scalations,
thats when an unprivileged normal user becomes superuser root, or an user can see other users stuff.

Caches and Temporary directories are mounted as private temporary unique autogenerated TMPFS,
meaning that the real ones can not be altered from within NimWC.

`noMnt=true` is for when you run 1 instance NimWC per server,
`noMnt=false` is for when you run multiple instances NimWC per server,
because it may or may not block other instances of accesing subfolders on `/mnt/` simultaneously.

`noX=false` if you are running a headless server or ChromeBook.
`noX=true` uses `Xvfb` for X Isolation (`xorg-server-xvfb`),
you may need to install it if you want to use it, but is not a hard dependency,
just use `noX=false` and you dont need to install it if you dont want to.

The features come from the Linux Kernel itself,
so theres zero cost on performance and the technology is already there even if you use it or not.

So in conclusion NimWC being compiled binary wont need access to most of your system,
just its own folder, the integration with Firejails hides everything else.

### Install
You local version of firejail to needs be >= `0.9.58`. Install using your package manager:
```
# Arch (package manager)
sudo pacman -S firejail

# Ubuntu (built files)
https://launchpad.net/ubuntu/+source/firejail/0.9.58-1 # <-- download
sudo apt install ./firejail_0.9.58-1_arm64.deb

# Compile
git clone https://github.com/netblue30/firejail.git
cd firejail
./configure && make && sudo make install-strip
```
</details>



# Resources

- [NimWC Logo, high quality, PNG.](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/public/images/logo)
- [NimWC Presentation Slides, HTML5 3D, English.](http://htmlpreview.github.io/?https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-presentation-presentation.html)
- [NimWC Presentation Slides, HTML5 3D, Spanish.](http://htmlpreview.github.io/?https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/docs/nimwc-presentation-es-presentation.html)
- [NimWC Telegram Stickers on the Nim Pack.](https://t.me/addstickers/nimlang)



# Videos

[<img src="https://img.youtube.com/vi/3R1l4Ha0tDI/maxresdefault.jpg" width="99%">](https://youtu.be/3R1l4Ha0tDI "NimWC Video!")


# Stars

[![Stars over time](https://starchart.cc/ThomasTJdev/nim_websitecreator.svg)](https://starchart.cc/ThomasTJdev/nim_websitecreator "Star NimWC on GitHub!")

