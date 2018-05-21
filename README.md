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


## Compiling / Installing

To compile and install you need [Nim](https://nim-lang.org/). You can easily install Nim using [choosenim](https://nim-lang.org/install_unix.html) with:
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

You only need to perform 1a **or** 1b - not both of them.


### 1a) Install:

If you are using [Nimble](https://github.com/nim-lang/nimble) an executable will be generated and symlinked to `websitecreator`, which then can be executed anywhere on your system.

```bash
# Install websitecreator with nimble
nimble install websitecreator

# Edit the config.cfg accordingly
# (change the confg.cfg path to your nimble folder and the correct package version)
nano ~/.nimble/pkgs/websitecreator-0.1.0/config/config.cfg

# Run websitecreator
# (to add an Admin user append "newuser": websitecreator newuser)
websitecreator
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

# Compile websitecreator
nim c -d:release -d:ssl websitecreator.nim

# Run websitecreator
# (to add an Admin user append "newuser": ./websitecreator newuser)
./websitecreator
```


## Compile/argument options:

*To use the options as arguments remove the `-d:` and append:*

* `-d:newdb` = Generates the database with standard tables (does **not** override or delete tables). `newdb` will be initialized automatic, if no database exists.
* `-d:newuser` = Add the Admin user
* `-d:insertdata` = Insert standard data (this will override existing data)
* `-d:nginx` = Used to close the streaming connection when using nginx as a webserver

*These options are only available at compiletime:*

* `-d:adminnotify` = Send error logs (ERROR) to the specified admin email
* `-d:dev` = Development
* `-d:devemailon` = Send email when `-d:dev` is activated
* `-d:demo` = Used on public test site [Nim Website Creator](https://nimwc.org)


## User profiles

There are 3 main user profiles:
* User
* Moderator
* Admin

The access rights below applies to main program. Plugins can have their own definition of user rights.

### User

The "User" can login and see private pages and blog pages. This user has no access to adding or editing anything.

### Moderator

The "Moderator" can login and see private pages and blog pages. This user **can** add and edit anything. The user **can** add and delete users, but cannot delete or add "Admin" users.

### Admin

The "Admin" has access to anything.


## Screenshots

Blog posts can be set as private or public.

**Blog**
![Blog](private/screenshots/blog.png)

**Blog page**
![Blog](private/screenshots/blog2.png)

**Blog post edit 1**
![Blog](private/screenshots/blogpage1.png)

**Blog post edit 2**
![Blog](private/screenshots/blogpage2.png)

**Frontpage**
![Frontpage](private/screenshots/frontpage.png)

**Settings**
![Blog](private/screenshots/settings.png)

**Settings head, header & footer**
![Blog](private/screenshots/settings2.png)

**Files**
![Blog](private/screenshots/files.png)

**Users**
![Blog](private/screenshots/users.png)

**Profile**
![Blog](private/screenshots/profile.png)


## Google reCAPTCHA

To activate Google reCAPTCHA claim you site and server key and insert them into you `config.cfg`.


## Plugins

Plugins will be loaded at compiletime with macros. Plugins are placed in the `plugins`-folder. Two example plugin (contact & mailer) are available and enabled in the `plugins`-folder.


### Enable a plugin

To enable a plugin add the path to the plugins and pluginname to `plugin/plugin_import.txt`:

```
# plugins = folder
# pluginname = the name of the plugin
plugins/pluginname

# eg. for the contact plugin:
plugins/contact
# eg. for the mailer plugin:
plugins/mailer
```

### Plugin structure

A plugin needs the following structure:

```
mailer/
  - html.tmpl   (optional)
  - mailer.nim  (required)
  - routes.nim  (required)
  - public/
    - js.js             (required) <- Will be appended to all pages
    - style.css         (required) <- Will be appended to all pages
    - js_private.js     (required) <- Needs to be imported manually
    - style_private.css (required) <- Needs to be imported manually
```

### mailer.nim
Includes the plugins proc()'s etc.

It is required to include a proc named `proc <pluginname>Start*(db: DbConn) =`

For the mailer plugin this would be: `proc mailerStart*(db: DbConn) =` . If this proc is not needed, just discard the content.


### routes.nim
Includes the URL routes.

It is required to include a route with `/<pluginname>/settings`. This page should show information about the plugin, and if the plugin has any options, which can be changed - this is the place.


### *.js and *.css

On compiletime `js.js`, `js_private.js`, `style.css` and `style_private.css` are copied from the plugins public folder to the official public folder, if the files contains text.

The files will be renamed to `mailer<_private>.js` and `mailer<_private>.css`.

A `<link>` and a `<script>` tag will be appended to the all pages, if `js.js` or `style.css` contains text.


## Available plugins

### Plugin: Backup

Create an instant backup file. Schedule continuously backups. Download backups.

You can access the plugin at `/backup`.


### Plugin: Mailer

Add mailselements containing subject, description and a date for sending the mail. Every 12th hour a cronjob will run to check, if it is time to send the mail.

All registrered users will receive the email.

You can access the plugin at `/mailer`. This link can be added to the navbar manually.


### Plugin: Contact

A simple contact form for non-logged in users. The email will be sent to the info-email specified in the `config.cfg` file.

You can access the plugin at `/contact`. This link can be added to the navbar manually.


### Plugin: Open registration

Opens up for public registration. Anyone can register an account and get a user with user role "User".

You can access the plugin at `/register`.


### Plugin: Themes

Switch between themes. Save custom themes from the browser.

You can access the plugin at `/themes`.