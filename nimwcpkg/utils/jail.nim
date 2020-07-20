
func makeCommand*(

    command: string, timeout: range[0..99] = 0, name = "",
    gateway = "", hostsFile = "", logFile = "", chroot = "", tmpfs = "",
    whitelist: seq[string] = @[], blacklist: seq[string] = @[],
    dnsServers: array[4, string] = ["", "", "", ""], maxSubProcesses = 0,
    maxOpenFiles = 0, maxFileSize = 0, maxPendingSignals = 0,
    maxRam = 0, maxCpu = 0, cpuCoresByNumber: seq[int] = @[],

    # All the Boolean options.
    apparmor, caps, no3d, noDbus, noDvd, noGroups, noNewPrivs, noRoot, noSound,
    noAutoPulse, noVideo, noU2f, noTv, privateTmp, private, privateCache, privateDev,
    seccomp, noX, noNet, noIp, appimage, useNice20, useMtuJumbo9000, newIpcNamespace,
    noMnt, noAllusers, noMachineId, noKeepDevShm, noDebuggers, noShell, noRamWriteExec,
    writables, forceEnUsUtf8, useRandomMac: bool

  ): string {.noinline.} =
  ## Generate a Firejail container command from arguments.

  var blancas: string
  if whitelist != @[]:
    for folder in whitelist:
      if folder.len > 1:
        assert folder notin ["~", "/dev", "/usr", "/etc", "/opt", "/var", "/bin", "/proc", "/media", "/mnt", "/srv", "/sys"]
        blancas.add "--whitelist='" & folder & "' "

  var negras: string
  if blacklist != @[]:
    for folder in blacklist:
      if folder.len > 1: negras.add "--blacklist='" & folder & "' "

  var denese: string
  if dnsServers != ["", "", "", ""]:
    for servo in dnsServers:
      if servo.len > 6: denese.add "--dns='" & servo & "' "

  var cpus: string
  if cpuCoresByNumber != @[]:
    for it in cpuCoresByNumber: cpus.add $it & ","


  result = (
    # The Firejail command itself.
    "firejail --noprofile " &

    # Debug when not release.
    (when defined(release): "--quiet " else: "--debug ") &

    # All the Boolean options.
    (if apparmor:        "--apparmor "      else: "") &
    (if caps:            "--caps "          else: "") &
    (if no3d:            "--no3d "          else: "") &
    (if noDbus:          "--nodbus "        else: "") &
    (if noDvd:           "--nodvd "         else: "") &
    (if noGroups:        "--nogroups "      else: "") &
    (if noNewPrivs:      "--nonewprivs "    else: "") &
    (if noRoot:          "--noroot "        else: "") &
    (if noSound:         "--nosound "       else: "") &
    (if noAutoPulse:     "--noautopulse "   else: "") &
    (if noVideo:         "--novideo "       else: "") &
    (if noU2f:           "--nou2f "         else: "") &
    (if noTv:            "--notv "          else: "") &
    (if privateTmp:      "--private-tmp "   else: "") &
    (if private:         "--private "       else: "") &
    (if privateCache:    "--private-cache " else: "") &
    (if privateDev:      "--private-dev "   else: "") &
    (if seccomp:         "--seccomp "       else: "") &
    (if noX:             "--x11=xvfb "      else: "") & # "none" complains about network.
    (if noNet:           "--net=none "      else: "") &
    (if noIp:            "--ip=none "       else: "") &
    (if appimage:        "--appimage "      else: "") &
    (if useNice20:       "--nice=20 "       else: "") &
    (if useMtuJumbo9000: "--mtu=9000 "      else: "") &
    (if newIpcNamespace: "--ipc-namespace " else: "") &
    (if noMnt:           "--disable-mnt "   else: "") &
    (if noAllusers:      ""                 else: "--allusers "       ) &
    (if noMachineId:     ""                 else: "--machine-id "     ) &
    (if noKeepDevShm:    ""                 else: "--keep-dev-shm "   ) &
    (if noDebuggers:     ""                 else: "--allow-debuggers ") &
    (if noShell:         "--shell=none "    else: "--shell=/bin/bash ") & #ZSH/Fish sometimes fail,force plain old Bash.
    (if noRamWriteExec:  "--memory-deny-write-execute " else: ""      ) &
    (if writables:       "--writable-etc --writable-run-user --writable-var --writable-var-log " else: "") &
    (if forceEnUsUtf8:   "--env=LC_CTYPE='en_US.UTF-8' --env=LC_NUMERIC='en_US.UTF-8' --env=LC_TIME='en_US.UTF-8' --env=LC_COLLATE='en_US.UTF-8' --env=LC_MONETARY='en_US.UTF-8' --env=LC_MESSAGES='en_US.UTF-8' --env=LC_PAPER='en_US.UTF-8' --env=LC_NAME='en_US.UTF-8' --env=LC_ADDRESS='en_US.UTF-8' --env=LC_TELEPHONE='en_US.UTF-8' --env=LC_MEASUREMENT='en_US.UTF-8' --env=LC_IDENTIFICATION='en_US.UTF-8' --env=LC_ALL='en_US.UTF-8' --env=LANG='en_US.UTF-8' " else: "") &

    # All the options with arguments.
    (if timeout != 0:           "--timeout='" & $timeout & ":00:00' "        else: "") &
    (if gateway != "":          "--defaultgw='" & gateway & "' "             else: "") &
    (if hostsFile != "":        "--hosts-file='" & hostsFile & "' "          else: "") &
    (if chroot != "":           "--chroot='" & chroot & "' "                 else: "") &
    (if tmpfs != "":            "--tmpfs='" & tmpfs & "' "                   else: "") &
    (if maxRam != 0:            "--rlimit-as='" & $maxRam & "' "             else: "") &
    (if maxCpu != 0:            "--rlimit-cpu='" & $maxCpu & "' "            else: "") &
    (if maxFileSize != 0:       "--rlimit-fsize='" & $maxFileSize & "' "     else: "") &
    (if maxOpenFiles != 0:      "--rlimit-nofile='" & $maxOpenFiles & "' "   else: "") &
    (if maxSubProcesses != 0:   "--rlimit-nproc='" & $maxSubProcesses & "' " else: "") &
    (if cpuCoresByNumber != @[]: "--cpu='" & cpus[0..^2] & "' "              else: "") &
    (if maxPendingSignals != 0: "--rlimit-sigpending='" & $maxPendingSignals & "' " else: "") &
    (if name != "":             "--name='" & name & "' --hostname='" & name & "' "  else: "") &
    (if logfile != "":          "--output='" & logFile & "' --output-stderr='" & logFile & "' " else: "") &

    # Variables and the command itself.
    denese & blancas & negras & command
  )


#[

when isMainModule:
  echo makeCommand(
    command = "echo 42", timeout = 99, name = "myAppName", gateway = "10.0.0.1",
    hostsFile = "/etc/hosts", logfile = "/tmp/myApp.log", chroot = "/tmp/chroot/",
    tmpfs = "/tmp/tmpfs", dnsServers = ["8.8.8.8", "8.8.4.4", "1.1.1.1", "1.1.1.2"],
    whitelist = @["/tmp/one", "/tmp/two"], blacklist = @["/usr/bin", "/share/bin"],
    maxSubProcesses = int8.high, maxOpenFiles = int8.high, maxFileSize = int32.high,
    maxPendingSignals = int16.high, maxRam = int16.high, maxCpu = int32.high,
    cpuCoresByNumber = @[0, 2],

    noAllusers = false, apparmor = false, caps = true, noKeepDevShm = false,
    noMachineId = false, noRamWriteExec = true, no3d = true, noDbus = true,
    noDvd = true, noGroups = true, noNewPrivs = true, noRoot = true, noSound = true,
    noAutoPulse = true, noVideo = true, forceEnUsUtf8 = true, noU2f = true,
    privateTmp = true, private = true, privateCache = true, noMnt = true,
    privateDev = true, seccomp = true, noShell = true, noNet = true, noIp = true,
    noDebuggers = false, newIpcNamespace = true, appimage = true, noTv = true,
    useMtuJumbo9000 = true, useNice20 = true, noX = true, useRandomMac = true,
    writables = false
  )

#]
