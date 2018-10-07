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