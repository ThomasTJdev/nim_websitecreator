# Nim Website Creator

A quick website tool. Run the nim file and access your webpage.

Online test page: [Nim Website Creator](https://nimwc.org)


## Main features:
- Webserver hosting your page on 127.0.0.1:7000
- Blog - add and edit blog posts
- Pages - add and edit pages
- Custom head, navbar and footer
- Edit js/js.js and css/style.css
- Define your own JS and CSS imports
- Upload files (private or public)
- Multiple users
- Add plugins

## Requirements
- Linux
- Nim
- Nim modules (automated when using Nimble):
  - jester >= 0.2.0
  - reCAPTCHA >= 1.0.2
  - bcrypt >= 0.2.1


## Upgrading from 1.0.3
*Inspired by https://github.com/nim-lang/nimforum/*

Sessions is now used. Therefore, you need to make som changes to your database. This is only applicable if your database is created in versions below 1.0.4.

In the session table password has been renamed to key - this is essential. In the person table the VARCHAR length has been expanded to 300 from 110 - this is optional.

```
cd data
echo '.dump' | sqlite3 website.db > upgrade.dump
# Find and change:
# 1a) password varchar(110) not null
# to
# 1b) password varchar(300) not null,
#
# 2a) password $# not null,
# to
# 2b) key $# not null,
cat upgrade.dump | sqlite3 website.db
```


# Compiling / Installing

To compile and install you need [Nim](https://nim-lang.org/). You can easily install Nim using [choosenim](https://nim-lang.org/install_unix.html) with:
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

You only need to perform 1a **or** 1b - not both of them.


## 1a) Install:

If you are using [Nimble](https://github.com/nim-lang/nimble) an executable will be generated and symlinked to `nimwc`, which then can be executed anywhere on your system.

```bash
# Install nimwc with nimble
nimble install nimwc

# Edit the config.cfg accordingly
# (change the confg.cfg path to your nimble folder and the correct package version)
nano ~/.nimble/pkgs/nimwc-0.1.0/config/config.cfg

# Run nimwc
# (to add an Admin user append "newuser": nimwc newuser)
nimwc
```


## 1b) Compile:

This will generate the executable in the folder. 

```bash
# Clone the repository
git clone https://github.com/ThomasTJdev/nim_nimwc
cd nim_nimwc

# Generate and edit the config.cfg accordingly
cp config/config_default.cfg config/config.cfg
nano config.cfg

# Compile nimwc
nim c -d:ssl nimwc.nim

# Run nimwc
# (to add an Admin user append "newuser": ./nimwc newuser)
./nimwc

# To recompile just add compileoption -d:rc
```


## Argument (args):

*These args should be prepended to file, e.g. ./nimwc newuser:*

* `newuser` = Add the Admin user. The `-u:<username>`, `-p:<password>` and `-e:<email>` args are required
  * `-u:<admin username>`
  * `-p:<admin password>`
  * `-e:<admin email>`
* `nginx` = Used to close the streaming connection when using Nginx as a webserver
* `insertdata` = Insert standard data (this will override existing data)
* `newdb` = Generates the database with standard tables (does **not** override or delete tables). `newdb` will be initialized automatic, if no database exists.

## Compile options:

*These options are only available at compiletime:*

* `-d:nginx` = Used to close the streaming connection when using nginx as a webserver
* `-d:adminnotify` = Send error logs (ERROR) to the specified admin email
* `-d:dev` = Development
* `-d:devemailon` = Send email when `-d:dev` is activated
* `-d:demo` = Used on public test site [Nim Website Creator](https://nimwc.org)
* `-d:demoloadbackup` = Used with -d:demo. This option will override the database each hour with the file named `website.bak.db`. You can customize the page and make a copy of the database and name it `website.bak.db`, then it will be used by this feature.


# User profiles

There are 3 main user profiles:
* User
* Moderator
* Admin

The access rights below applies to main program. Plugins can have their own definition of user rights.

## User

The "User" can login and see private pages and blog pages. This user has no access to adding or editing anything.

## Moderator

The "Moderator" can login and see private pages and blog pages. This user **can** add and edit anything. The user **can** add and delete users, but cannot delete or add "Admin" users.

## Admin

The "Admin" has access to anything.

# Plugins

Multiple plugins are available. You can download them within the program at `<webpage>/plugins/repo`.

The plugin repo are located here: [NimWC plugin repo](https://github.com/ThomasTJdev/nimwc_plugins)


# Shortcuts

When editing a blogpage or normal page press Ctrl+S to save.

# Google reCAPTCHA

To activate Google reCAPTCHA claim you site and server key and insert them into you `config.cfg`.

# systemctl

## Service file

Create a new file called nimha.service inside /lib/systemd/system/nimwc.service

```
[Unit]
Description=nimwc
After=network.target

[Service]
User=ubuntu
Type=simple
WorkingDirectory=/home/<user>/.nimble/pkgs/nimwc-1.0.0/
ExecStart=/home/<user>/.nimble/pkgs/nimwc-1.0.0/nimwc
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

## Enable auto start and start it:
```
sudo systemctl enable nimwc
sudo systemctl start nimwc
sudo systemctl status nimwc
```


# Trouble

Remove nimcache and nimwcpkg/nimcache and re-compile