# Nim Website Creator

A quick website tool. Run the nim file and access your webpage. Website: [https://nimwc.org](https://nimwc.org)

<img src="private/screenshots/NimWC_logo_shadow.png" style="max-height: 250px; display: block;" />


## Main features:

- Webserver hosting your page on 127.0.0.1:7000
- Edit your pages with Summernote, raw HTML (CodeMirror) or drag'n'drop with GrapesJS
- Blog - add and edit blog posts
- Pages - add and edit pages
- Custom head, navbar and footer
- Custom title, meta description and keywords for each page
- Edit core or custom js- and css-files
- Upload files (private or public)
- Postgres SQL Database Server with ORM.
- Log Viewer directly from browser.
- Auto-Rotating file Logger.
- Uses responsive Bulma CSS framework, supports Bootstrap CSS framework.
- JavaScript framework agnostic, use Nim, Karax, vanilla JS, you choose.
- Colored output on the Terminal.
- Plugin skeleton creator.
- Multiple users
- Add plugins


## Requirements

- Linux
- Nim >= `0.19.2`
- Nim modules (automated when using Nimble):
  - jester >= `0.4.1`
  - reCAPTCHA >= `1.0.2`
  - bcrypt >= `0.2.1`


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
nano ~/.nimble/pkgs/nimwc-1.1.0/config/config.cfg

# Run nimwc
# (to add an Admin user append "newuser": nimwc --newuser -u:admin -p:pass -e:a@a.com)
# (to include some standard pages: nimwc --insertdata)
nimwc

# Login
127.0.0.1:7000/login
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
# (to add an Admin user append "--newuser": ./nimwc --newuser -u:admin -p:pass -e:a@a.com)
# (to include some standard pages: nimwc --insertdata)
./nimwc

# Login
127.0.0.1:7000/login
```


## Argument (args):

These arguments should be prepended to executable file, e.g. `./nimwc cdata`

* `--newuser` = Add the Admin user. The `-u:<username>`, `-p:<password>` and `-e:<email>` args are required. E.g. `--newuser -u:admin -p:pass -e:a@a.com`
  * `-u:<admin username>`
  * `-p:<admin password>`
  * `-e:<admin email>`
* `--insertdata` = Insert standard data (this will override existing data)
  * `bulma` = Use Bulma CSS
  * `bootstrap` = Use Bootstrap and jQuery
  * `clean` = No framework is used
* `--newdb` = Generates the database with standard tables (does **not** override or delete tables). `newdb` will be initialized automatic, if no database exists.
* `--gitupdate` = Updates and force a hard reset
* `--initplugin` = Create plugin skeleton inside tmp/

## Compile options:

These options are only available at compiletime:

* `-d:rc` = Recompile. NimWC is using a launcher, it is therefore needed to force a recompile.
* `-d:adminnotify` = Send error logs (ERROR) to the specified admin email
* `-d:dev` = Development
* `-d:devemailon` = Send email when `-d:dev` is activated
* `-d:demo` = Used on public test site [Nim Website Creator](https://nimwc.org). This option will override the database each hour with the standard data.
* `-d:gitupdate` = Updates and force a hard reset


# User profiles

There are 3 main user profiles:
* User
* Moderator
* Admin

The access rights below applies to main program. Plugins can have their own definition of user rights.

## User

The "User" can login and see private pages and blog pages. This user has no access to adding or editing anything.

## Moderator

The "Moderator" can login and see private pages and blog pages. The user **can** add and delete users, but cannot delete or add "Admin" users. The user **cannot** edit JS, CSS and core HTML - only within the pages and blogposts.

## Admin

The "Admin" has access to anything.

# Blog

You can easily add and edit blogpages. The blogpages support metadata: meta description and meta keywords. It is also possible to specify a category and tags.

## Blog sorting

In the settings menu you can specify how your blogposts should be sorted, e.g. on modfied date in ascending order.

## Blog searching

To only show blogpost with a specific name, tag or category, you have to append the criteria to the URL. It is not possible to combine these.

```
website.com/blog?name=nim
website.com/blog?category=article
website.com/blog?tags=code
```

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
WorkingDirectory=/home/<user>/.nimble/pkgs/nimwc-2.0.0/ # MODIFY to your installation path
ExecStart=/home/<user>/.nimble/pkgs/nimwc-2.0.0/nimwc   # MODIFY to your installation path
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

# GrapesJS
GrapesJS is a Web Builder Framework. To use GrapeJS with a CSS framework (Bulma or Bootstrap), you have to edit `public/js/grapejs_custom.js` and `public/js/grapejsbs4.min.js`. Bootstrap support in `public/js/grapejs_custom.js` is commented out.

# Trouble

Remove `nimcache` and `nimwcpkg/nimcache` and re-compile


# Docker

- [Use the Dockerfile](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/Dockerfile) as starting point for your NimWC containers.
