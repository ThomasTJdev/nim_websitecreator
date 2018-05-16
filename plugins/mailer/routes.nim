  get "/mailer/settings":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genMailerSettings(c))

  get "/mailer":
    createTFD()
    if c.loggedIn:
      resp genMain(c, genMailerMain(c, db))

  get "/mailer/all":
    createTFD()
    if c.loggedIn:
      resp genMain(c, genMailerMain(c, db, false))

  get "/mailer/add":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genMailerAdd(c, db))

  post "/mailer/doadd":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let addStatus = mailerAddMailevent(c, db)
      if addStatus == "OK":
        redirect("/mailer")
      else:
        resp(addStatus)

  post "/mailer/doupdate":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, mailerUpdateMailevent(c, db))

  get "/mailer/delete":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      mailerDelete(c, db)
      redirect("/mailer")

  get "/mailer/mail":
    createTFD()
    if c.loggedIn:
      resp genMain(c, genMailerViewMail(c, db, c.req.params["mailid"]))

  get "/mailer/testmail":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      mailerTestmail(c, db)
      redirect("/mailer")