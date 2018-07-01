# Nim Website Creator

A quick website tool. Run the nim file and access your webpage. Website: [https://nimwc.org](https://nimwc.org)

<img src="private/screenshots/NimWC_logo_shadow.png" style="max-height: 250px; display: block;" />


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


# Compiling / Installing

## Install Nim
To compile and install you need [Nim](https://nim-lang.org/). You can easily install Nim using [choosenim](https://nim-lang.org/install_unix.html) with:
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

## Install NimWC

You only need to perform 1a **or** 1b - not both of them.


### 1a) Install:

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


### 1b) Compile:

This will generate the executable in the folder. 

```bash
# Clone the repository
git clone https://github.com/ThomasTJdev/nim_websitecreator
cd nim_websitecreator

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

These arguments should be prepended to executable file, e.g. `./nimwc insertdata`

* `newuser` = Add the Admin user. The `-u:<username>`, `-p:<password>` and `-e:<email>` args are required
  * `-u:<admin username>`
  * `-p:<admin password>`
  * `-e:<admin email>`
* `nginx` = Used to close the streaming connection when using Nginx as a webserver
* `insertdata` = Insert standard data (this will override existing data)
* `newdb` = Generates the database with standard tables (does **not** override or delete tables). `newdb` will be initialized automatic, if no database exists.

## Compile options:

These options are only available at compiletime:

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

The plugin repository are located here: [NimWC plugin repository](https://github.com/ThomasTJdev/nimwc_plugins)


# Shortcuts

When editing a blogpage or a normal page press Ctrl+S to save.

# Google reCAPTCHA

To activate Google reCAPTCHA [claim you site and server key](https://www.google.com/recaptcha/admin) and insert them into `config.cfg`.

# Autorun - systemctl

## Service file

Create a new file called nimwc.service inside /lib/systemd/system/:
```
sudo nano /lib/systemd/system/nimwc.service
```

Add the following to the file:
```
[Unit]
Description=nimwc
After=network.target

[Service]
User=ubuntu # MODIFY to your username
Type=simple
WorkingDirectory=/home/<user>/.nimble/pkgs/nimwc-1.0.0/ # MODIFY to your installation path
ExecStart=/home/<user>/.nimble/pkgs/nimwc-1.0.0/nimwc   # MODIFY to your installation path
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

Remove `nimcache` and `nimwcpkg/nimcache` and re-compile