# Nim Website Creator

A quick website tool. Run the nim file and access your webpage. Website: [https://nimwc.org](https://nimwc.org)

<img src="private/screenshots/NimWC_logo_shadow.png" style="max-height: 250px; display: block;" />


# Features

- Self-Firejailing Web Framework (It Firejails itself) Best Linux Security integrated on the Core.
- High performance with low resources (Rasp Pi, VPS, cloud, old pc, etc).
- [Postgres](https://www.postgresql.org) or SQLite Databases with ORM.
- SQL Type-checked and Query-checked at compile-time, no SQL injections.
- Uses responsive [Bulma CSS framework](https://bulma.io), supports [Bootstrap CSS framework](https://getbootstrap.com).
- JavaScript framework agnostic, use Nim, [Karax](https://github.com/pragmagic/karax), vanilla JS, you choose.
- WYSIWYG & Drag'n'Drop Editors with [Summernote](https://summernote.org), [CodeMirror](https://codemirror.net) or [GrapesJS](https://grapesjs.com).
- Webserver hosting your page on 127.0.0.1:7000
- 1 Click Blogging posts directly from browser.
- 1 Click Static web pages directly from browser.
- Upload files and images (private or public) directly from browser.
- Plugin manager to install, enable and disable plugins directly from browser.
- Custom title, meta description and keywords for each page, SEO friendly.
- Custom head, navbar and footer, no hardcoded watermarks, links or logos.
- Edit core or custom JS and CSS directly from browser, UI/UX Designer friendly.
- WebP automatic Image and Photo Optimizations.
- Unsplash integrated to access the biggest free collection of images.
- Log Viewer directly from browser.
- Auto-Rotating file Logger.
- Server Info Page for Admins.
- Force Server restart for Admins.
- Reconfiguration & Recompilation without down times.
- Colored output on the Terminal.
- Plugin skeleton creator to create your own new plugins.
- Plugins can do anything you want on Frontend and Backend.
- Multiple users with different ranks.
- 0 Dependency binary (Postgres required if using it, nothing required for SQLite).
- Runs on any non-Windows OS, Architecture and Hardware that can compile C code.
- High Availability design by default.
- No `/node_modules/`, but very powerful builtin Templating engine.
- 2 Factor Athentication TOTP + ReCaptcha + HoneyPot-Field, by default. 🙂🔐
- BCrypt+Salt password hashing, 4 chars min for Demo, 10 chars min for Production.
- [NGINX Config, SystemD Service, Vagrantfile and Dockerfile provided for DevOps.](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/)


# Requirements

To get started you only need:

- Linux (For Windows [see Docker-for-Windows](http://docs.docker.com/docker-for-windows))
- Nim >= `0.19.2`

<details>

Development Dependencies (automatically installed by Nimble):

- Jester    >= `0.4.1`
- Gatabase  >= `0.2.0`
- reCAPTCHA >= `1.0.2`
- bCrypt    >= `0.2.1`
- datetime2human >= `0.2.2`
- otp       >= `0.1.1`
- firejail  >= `0.4.0`
- webp      >= `0.1.0`
- unsplash  >= `0.1.0`

</details>


# Install

## Install Nim

To compile and install you need [Nim](https://nim-lang.org/). You can easily install Nim using [choosenim](https://nim-lang.org/install_unix.html) with:

```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

## Install NimWC

You only need to perform 1a **or** 1b - not both of them.


### 1a) Install

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


### 1b) Compile

<details>

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

</details>


# Use

**Arguments**

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


# GrapesJS

GrapesJS is a Web Builder Framework. To use GrapeJS with a CSS framework (Bulma or Bootstrap), you have to edit `public/js/grapejs_custom.js` and `public/js/grapejsbs4.min.js`. Bootstrap support in `public/js/grapejs_custom.js` is commented out.


# DevOps

<details>
  <summary>Docker, Vagrant, SystemD Service, NGNIX, Admin stuff, etc</summary>

**Docker**

- [Use the Dockerfile](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/Dockerfile) as starting point for your NimWC containers.


**Vagrant**

- [Use the Vagrantfile](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/Vagrantfile) as starting point for your NimWC VMs.


**NGNIX Config**

- [Use the NGNIX Config file](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/Vagrantfile) as starting point for your NGNIX Server configuration.


**Google reCAPTCHA**

To activate Google reCAPTCHA [claim you site and server key](https://www.google.com/recaptcha/admin) and insert them into `config.cfg`.


**SystemD**

- [Use the SystemD Service file](https://github.com/ThomasTJdev/nim_websitecreator/blob/master/Vagrantfile) as starting point for your NimWC SystemD Services.

Copy the file called `nimwc.service` inside `/lib/systemd/system/`

```
sudo nano /lib/systemd/system/nimwc.service
```

## Enable auto start and start it:
```
sudo systemctl enable nimwc
sudo systemctl start nimwc
sudo systemctl status nimwc
```


</details>
