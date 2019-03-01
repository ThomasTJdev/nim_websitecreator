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
