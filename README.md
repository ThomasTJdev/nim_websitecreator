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

To compile (and install) you need [Nim](https://nim-lang.org/). You can easily [install Nim](https://nim-lang.org/install_unix.html) with:
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
```

### 1) Config:

Rename `config_default.cfg` to `config.cfg` and insert your data.

You only need to perform 2a **or** 2b - not both of them.


### 2a) Install:

If you are using [Nimble](https://github.com/nim-lang/nimble) an executable will be generated and symlinked to `websitecreator`, which then can be executed anywhere on your system.

```
nimble install nim_websitecreator
websitecreator
```


### 2b) Compile:

This will generate the executable in the folder. 

**Please see the section below regarding the first run (first compile).**

```
nim c -d:release -d:ssl websitecreator.nim
./websitecreator
```


## First run:

On the first run it is advised to use the parameters below, which will create the database, add an admin user and insert base data.

You can either compile the program with parameters (-d:) or add the parameters as command line arguments. You only need to perform 1a **or** 1b - not both of them.

Arguments can also be used after compiling the program or after installing the progam with Nimble.


### 1a) Arguments on first run

Install the program with Nimble and then:

```
./websitecreator.nim newdb newuser insertdata
```


### 1b) Compile on first run

First run:

```
nim c -d:release -d:ssl -d:newdb -d:newuser -d:insertdata websitecreator.nim
```

Then run:

```
nim c -r -d:release -d:ssl websitecreator.nim
```


## Compile/argument options:

*To use the options as arguments remove the `-d:`*

* `-d:newdb` = Generate the database
* `-d:newuser` = Add an admin user
* `-d:insertdata` = Insert base data
* `-d:nginx` = Used to close the streaming connection when using nginx as a webserver
* `-d:adminnotify` = Send error logs (ERROR) to the specified admin email
* `-d:dev` = Development
* `-d:devemailon` = Send email when `-d:dev` is activated
* `-d:demo` = Used on public test site [Nim Website Creator](https://nimwc.org)


## Content

Blog posts can be set as private or public.

**Blog**
![Blog](private/screenshots/blog.png)

**Blog page**
![Blog](private/screenshots/blog2.png)

**Blog post edit 1**
![Blog](private/screenshots/blogpage1.png)

**Blog post edit 2**
![Blog](private/screenshots/blogpage2.png)


## Screenshot

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

Plugins will be loaded at compiletime with macros. Plugins are placed in the `plugins`-folder. Two example plugin (contact & mailer) are available in the `plugins`-folder.


### Enable a plugin

To enable a plugin add the following lines to `plugin/plugin_import.txt`:

```
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


### *.js and *.css

On compiletime `js.js`, `js_private.js`, `style.css` and `style_private.css` are copied from the plugins public folder to the official public folder, if the files contains text.

The files will be renamed to `mailer<_private>.js` and `mailer<_private>.css`.

A `<link>` and a `<script>` tag will be appended to the all pages, if `js.js` or `style.css` contains text.


### Plugin: Mailer

Add mailselements containing subject, description and a date for sending the mail. Every 12th hour a cronjob will run to check, if it is time to send the mail.

All registrered users will receive the email.

You can access the plugin at `/mailer`. This link can be added to the navbar manually.


### Plugin: Contact

A simple contact form for non-logged in users. The email will be sent to the info-email specified in the `config.cfg` file.

You can access the plugin at `/contact`. This link can be added to the navbar manually.