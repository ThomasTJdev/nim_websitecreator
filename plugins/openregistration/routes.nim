  get "/register":
    createTFD()
    if openregistrationCheck():
      if c.loggedIn or c.rank != NotLoggedin:
        redirect("/error/" & encodeUrl("You are already logged in"))
      else:
        resp genUsersRegister(db)


  post "/register":
      createTFD()
      if c.loggedIn or c.rank != NotLoggedin:
        redirect("/error/" & encodeUrl("You are already logged in"))

      elif openregistrationCheck():
        when not defined(dev):
          if useCaptcha:
            if not await checkReCaptcha(@"g-recaptcha-response", c.req.ip):
              resp genUsersRegister(db, "Error: You need to verify, that you are not a robot!")


        when defined(demo):
          if c.email == "test@test.com":
            redirect("/error/" & encodeUrl("Error: The test user can not add new users"))

        if @"name" == "" or @"email" == "":
          resp genUsersRegister(db, "Error: Name, email and status are required")

        if @"email" == "test@test.com":
          resp genUsersRegister(db, "Error: test@test.com is taken by the system")
        
        let (regiB, regiS) = openregistrationRegister(db, @"name", @"email")

        if regiB:
          resp genFormLogin(c, "Please click on the confirmation link in your email")
        else:
          resp genUsersRegister(db, regiS)
