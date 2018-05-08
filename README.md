# Nim Website Creator

A quick website tool. Run the nim file and access your webpage.

## Main features:
- Webserver hosting your page on 127.0.0.1:7000
- Blog - add and edit blog posts
- Pages - add and edit pages
- Custom head, navbar and footer
- Define your own JS and CSS imports
- Upload files (private or public)
- Multiple users
- Edit js/js.js and css/style.css
- Add plugins

## Compile

**Config:**

Rename `config_default.cfg` to `config.cfg` and insert your data.

**Compile:**

`nim c -d:release -d:ssl websitecreator.nim`

**First run:**

On the first run it is advised to use the following parameters:

`nim c -d:release -d:ssl -d:newdb -d:newuser -d:insertdata websitecreator.nim`

**Options:**
* `-d:nginx` = Used to close the streaming connection when using nginx as a webserver
* `-d:newdb` = Generate the database
* `-d:newuser` = Add an admin user
* `-d:insertdata` = Insert base data
* `-d:dev` = Development
* `-d:devemailon` = Send email when `dev` is activate

## Content

Blog posts can be set as private or public.

**Blog**
![Blog](screenshots/blog.png)

**Blog post edit 1**
![Blog](screenshots/blogpage1.png)

**Blog post edit 2**
![Blog](screenshots/blogpage2.png)

## Plugins

Plugins will be loaded at compiletime with macros. Plugins are placed in `plugins`-folder. An example plugin (mailer) is available in the `plugins`-folder.

### Plugin structure

A plugin needs the following structure:

```
mailer/
  - html.tmpl (optional)
  - mailer.nim (required)
  - routes.nim (required)
  - update.sql (optional)
  - public/
    - js.js
    - style.css
```

### mailer.nim
Includes the proc() etc.

It is required to include a proc named `proc mailerStart*(db: DbConn) =`. If this proc is not needed, just discard the content.

### routes.nim
Includes the URL routes.

On compiletime the js and css file in the public folder will be copied to the official public folder, and a `<link>` and `<script>` tag will be appended to the HTML code.

## Screenshot

**Frontpage**
![Frontpage](screenshots/frontpage.png)

**Settings**
![Blog](screenshots/settings.png)

**Settings head, header & footer**
![Blog](screenshots/settings2.png)

**Files**
![Blog](screenshots/files.png)

**Users**
![Blog](screenshots/users.png)

**Profile**
![Blog](screenshots/profile.png)