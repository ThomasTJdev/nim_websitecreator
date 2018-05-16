  get "/contact/settings":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genContactSettings(c))
  
  get "/contact":
    createTFD()
    resp genMain(c, genContactMain(c, db))

  get "/contact/send":
    createTFD()
    resp genMain(c, genContactSend(c, db, @"data"))

  post "/contact/send":
    createTFD()

    when not defined(dev):
      if useCaptcha:
        if not await checkReCaptcha(@"g-recaptcha-response", c.req.ip):
          resp genMain(c, genFormLogin(c, "Error: You need to verify, that you are not a robot!"))

    let content = @"content"
    let senderName = @"name"
    let senderEmail = @"email"

    if @"content" == "" or @"name" == "" or @"email" == "":
      redirect("/contact/send?data=" & encodeUrl("Your name, email and mail content are required"))

    redirect("/contact/send?data=" & encodeUrl(contactSendMail(c, db, content, senderEmail, senderName)))