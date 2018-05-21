  get "/backup/settings":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genBackupSettings(c, db, @"msg"))

  get "/backup/newbackuptime":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if not isDigit(@"backuptime") or "." in @"backuptime":
        redirect("/backup/settings?msg=" & encodeUrl("Backup time needs to be a whole number. You provided: " & @"backuptime"))  

      if tryExec(db, sql"UPDATE backup SET backuptime = ?, modified = ? WHERE id = ?", @"backuptime", toInt(epochTime()), "1"):
        asyncCheck cronBackup(db)
        redirect("/backup/settings")

      else:
        redirect("/backup/settings?msg=" & encodeUrl("Something went wrong!"))

  get "/backup/loadbackup":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if fileExists("data/" & @"backupname"):
        let execOutput = execCmd("cp data/" & @"backupname" & " data/website.db")
        if execOutput == 0:
          redirect("/backup/settings?msg=" & encodeUrl("Backup \"" & @"backupname" & "\" was loaded."))  
        else:
          redirect("/backup/settings?msg=" & encodeUrl("Error, the backup could not be loaded.")) 
      
      redirect("/backup/settings?msg=" & encodeUrl("Error, no backup with that name was found."))  

  get "/backup/backupnow":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if backupNow():
        redirect("/backup/settings")
      else: 
        redirect("/backup/settings?msg=" & encodeUrl("Error, something went wrong creating the backup."))  

  get "/backup/download":
    ## Get a file
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let filename = @"backupname"
      
      var filepath = "data/" & filename

      if not fileExists(filepath):
        redirect("/backup/settings?msg=" & encodeUrl("Error, the backup file was not found with the name: " & filename))  
        
      # Serve the file
      let ext = splitFile(filename).ext
      await response.sendHeaders(Http200, {"Content-Disposition": "attachment", "filename": @"backupname", "Content-Type": "application/db"}.newStringTable())
      var file = openAsync(filepath, fmRead)
      var data = await file.read(4000)

      while data.len != 0:
        await response.client.send(data)
        data = await file.read(4000)
      
      file.close()
      
      if "nginx" notin commandLineParams() and not defined(nginx):
        response.client.close()