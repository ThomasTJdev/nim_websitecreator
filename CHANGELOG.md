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
ALTER TABLE pages ADD COLUMN title;
ALTER TABLE pages ADD COLUMN metadescription;
ALTER TABLE pages ADD COLUMN metakeywords;

ALTER TABLE blog ADD COLUMN title;
ALTER TABLE blog ADD COLUMN metadescription;
ALTER TABLE blog ADD COLUMN metakeywords;
```