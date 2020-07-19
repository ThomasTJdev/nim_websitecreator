# Database Queries for run-time use.
import db_common
import gatabase


const adminusers_createAdminUser0*: SqlQuery = sqls:
  select "id"
  `from` "person"
  where  "status = 'Admin'"

# echo adminusers_createAdminUser0.string


const adminusers_createAdminUser1*: SqlQuery = sqls:
  insertinto "person(name, email, password, salt, status)"
  values     5 # '?' * 5

# echo adminusers_createAdminUser1.string


const testusers_createTestUser0*: SqlQuery = sqls:
  select "id"
  `from` "person"
  where  "email = 'test@test.com'"

# echo testusers_createTestUser0.string


const testusers_createTestUser1*: SqlQuery = sqls:
  insertinto "person(name, email, password, salt, status)"
  values     5 # '?' * 5

# echo testusers_createTestUser1.string


const standarddatas_standardDataSettings0*: SqlQuery = sqls:
  insertinto "settings(title, head, navbar, footer)"
  values     4 # '?' * 4

# echo standarddatas_standardDataSettings0.string


const standarddatas_standardDataFrontpage0*: SqlQuery = sqls:
  insertinto "pages(author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords)"
  values     11

# echo standarddatas_standardDataFrontpage0.string


const standarddatas_standardDataBlogpost0*: SqlQuery = sqls:
  insertinto "blog(author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords)"
  values     11

# echo standarddatas_standardDataBlogpost0.string
