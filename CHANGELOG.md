## v6.0.6
## Changes
- Fixes and updates for Nim >= 1.2.4

## v6.0.3
## Changes
- Fix #121, #122 and #123
- Bug in uploading files to the public and private folder. A slash / was messing with the folder location.

## v6.0.2
### Changes
- Bug, if 2fa field was empty login was not possible.


## v6.0.1
### Changes
- Bug in loading recaptcha JS (crossorigin anonymous)
- Removed minifyhtml on demo HTML to give user pretty HTML to edit


## v6.0.0
### Changes
- Nim V1.0 compatible.
- PackedJSON Compile-Time optional compatible performance optimization, via `-d:packedjson` https://github.com/Araq/packedjson#packedjson
- Move static `const` very long strings to a dedicated `constants.nim` file, to keep code clean of long static strings.
- Version is now set using Nimbles `NimblePkgVersion` https://github.com/nim-lang/nimble/blob/master/changelog.markdown#0110---22092019
- Add proc `getConfig(path, section)` to get a `Table` of configs, to DRY reading configs.
- Add `--version-hash` to show Version (Git Short Hash).
- Add `--backupdb` Full backup of database (Raw SQL plain text file).
- Add `--backupdb-gpg` Compressed signed full backup of database (GPG+SHA512+TarGz).
- Add `--backuplogs` Compressed full backup of all old unused rotated Logs (TarGz).
- Add button for Admin that can Backup Database and Logs from Dashboard.
- Internal modules reorder for performance and DRY.
- Removed `--insertdata clean`, not too useful.
- Add `--insertdata water` Water CSS framework, No JS, classless HTML (No classes on HTML required), is like a better `--insertdata clean` https://u.nu/yosc
- Update Docs.
- Fix #119
- Minor bugs.


## v5.5.2
### Changes
- ReCaptcha compile flag missing + minor bugs


## v5.5.1
### Changes
- Contra preconditions check for salt removed due to random len
- If user does not have access to page (e.g. `/p/mypage`) redirect to `/`
- On startup it is checked, that the tables are present in the database
- Args `--insertdata`, post-conditions replaced with error message and user needs to confirm to avoid overwriting


## v5.5.0
### Changes
- Compatible with Nim >= `0.20.2`.
- `-d:hardened` Security Hardened mode via compile time flag, optional (based from Gentoo Hardened and Debian Hardened).
- `-d:contracts` Design by Contract mode via compile time flag, optional (similar to Ada, Eiffel, etc).
- `--backupdb` Compressed signed full backup of database. Vacuum database.
- `-d:recaptcha` Can enable/disable code generation for ReCaptcha at compile time.
- `--showconfig` Print to terminal the parsed INI configuration and compile options for debug.
- `connectDb()` Template injects `db` of type `DbConn` wherever you call it.
- Release builds are automatically stripped.
- Clean out code, update Readme, update docs, update help messages on terminal.
- No HTML/CSS/JS/UI/Visuals touched, nor added nor removed, no visual changes.
- Clean out, style fixes, performance fixes, etc.
- Refactor on command line arguments parsing.
- Update readme.
- Remove dependency on HTML_Tools package (used functions copied on html_utils).

Note: Security Hardened mode by definition has a performance cost (~20%).


## v5.1.1
### Changes
- Fixed bug in recompile function. Used when enabling/disabling plugins


## v5.1.0
### Changes
- Support for libravatar on profile picture
- Updated Bulma version
- Admin can reset user
- Design of plugin store is updated
- Design of user overview
- Design of user profile
- Copy NimWC log with 1 click
- Set uploaded files filename to lowercase or use MD5 checksum
- Custom appname
- Wrong order of params in lastOnline
- Docs added
- CSS class to hide or show blog categories
- Minify HTML

### Breaking changes
- Plugins.json structure changed
- New column in `person` table: `avatar`:
```sql
ALTER TABLE person ADD COLUMN avatar VARCHAR(300);
```
- A new param in the config.cfg file, which is used in the `<html lang="?">`:
```config
[Language]
standardLang = "en"
```


## v5.0.0
### Changes
- Add Server Info page for Admins, it displays runtime server stats
- Add Force Server Restart for Admins, restart on 1 second
- Update Bulma version
- Filter avatar image file format, because Crop thingy get buggy/slow with GIF
- 2 Factor Authentication
- Add MimeType, Size, CheckSum to Files page, useful for UI/UX building
- Add button to Copy all the Logs content on one click on Logs page
- Add Dockerfile to the repo
- Add Vagrantfile to the repo
- Add Service file to the repo
- Update Readme
- Update Nimble file
- First release of 2019

### Breaking changes
- New column in `person` table: `twofa`:
```sql
ALTER TABLE person ADD COLUMN twofa varchar(60);
```
- New column in `blog` table: `viewCount`:
```sql
ALTER TABLE blog ADD COLUMN viewCount INTEGER default 1;
```
- New column in `blog` table: `pubDate`:
```sql
ALTER TABLE blog ADD COLUMN pubDate VARCHAR(100);
```
- New table: `files`:
```nim
./nimwc --newdb
```
- Dependency [firejail](https://github.com/juancarlospaco/nim-firejail), install firejail on your system
- Dependency [webp](https://github.com/juancarlospaco/nim-webp-tools), install libwebp on your system


## v4.0.11
### Changes
- Remove min and max length on meta text
- Include blogsort when creating database


## v4.0.10
### Changes
- Redirect to "/" when not logged in and accessing users/<profile>


## v4.0.9
### Changes
- Admin user was not added


## v4.0.8
### Changes
- Front slash is preserved in the url for blogposts and pages
- Styling of tags and categories on blogposts


## v4.0.7
### Changes
- Support for category and tags on blogposts
- `-d:demoloadbackup` is removed
- Testuser can not edit pages


## v4.0.6
### Changes
- Fix robots.txt to avoid problems with Google Webmaster
- Fix #29, #31


## v4.0.5
### Changes
- Drop Bootstrap+JQuery, Add Bulma CSS Framework, but still support Bootstrap.
- Try to not depend on OS commands like `cp`, `ln`, etc.
- Add simple Logs Viewer directly from browser.
- Add Auto-Rotating file Logger.
- De-Branded by default.
- Code Clean out.
- UI Redesign.
- Allow special chars in url with `encodeUrl(@"url", true)`


## v4.0.4
### Changes
- Include meta info on pages


## v4.0.2
### Changes
- The user are prompted before deleting a file, page and blogpost.


## v4.0.0
### Changes
- When adding a new page only basic information is available. Right after saving the new page, the user is redirected to the editing page.
- When viewing all the blogpost the metadescription is inserted below.


## v3.2.0
### Changes
- Include Summernote as editor


## v3.1.1
### Changes
- Custom blog order

### Breaking changes
- Database tables ``settings`` has been updated with the columns: ``blogorder``.
```sql
/*
Update your SQLite database with the following queries.

$ sqlite3 data/website.db
$ [paste and run]
*/
ALTER TABLE settings ADD COLUMN blogorder TEXT;
ALTER TABLE settings ADD COLUMN blogsort TEXT;
```


## v3.0.0
### Changes
- Bugfixes
- Improved design
- Cleaned up some code (DRY)
- Added ``js_custom.js`` and ``style_custom.css`` to avoid changing in core js and css

### Breaking changes
- Custom ``sitemap.xml`` and ``robots.txt`` in the folder ``public/`` will be overwritten.
- Admin console (pages accessed from settings) now has static core CSS, JS and background images. Changes to ``js.js`` and ``style.css`` will only affect user pages.
- Database tables ``pages`` and ``blogpost`` has been updated with the columns: ``title``, ``metadescription`` and ``metakeywords``.
```sql
/*
Update your SQLite database with the following queries.

$ sqlite3 data/website.db
$ [paste and run]
*/
ALTER TABLE pages ADD COLUMN title TEXT;
ALTER TABLE pages ADD COLUMN metadescription TEXT;
ALTER TABLE pages ADD COLUMN metakeywords TEXT;

ALTER TABLE blog ADD COLUMN title TEXT;
ALTER TABLE blog ADD COLUMN metadescription TEXT;
ALTER TABLE blog ADD COLUMN metakeywords TEXT;
```
