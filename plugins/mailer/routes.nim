# Copyright 2018 - Thomas T. Jarløv

of "mailer":
  return mailerMain(c, db)

of "mailer/add":
  return mailerAdd(c, db)

of "mailer/doadd":
  return mailerAddMailevent(c, db)

of "mailer/doupdate":
  return mailerUpdateMailevent(c, db)

of "mailer/delete":
  return mailerDelete(c, db)

of "mailer/mail":
  return mailerViewMail(c, db)

of "mailer/testmail":
  return mailerTestmail(c, db)