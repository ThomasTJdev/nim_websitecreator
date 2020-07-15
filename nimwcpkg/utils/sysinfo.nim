import os, osproc, json, strutils, posix, posix_utils

template isSsd(): bool =
  when defined(linux): # Returns `true` if main disk is SSD (Solid). Linux only
    try: readFile("/sys/block/sda/queue/rotational") == "0\n" except: false

proc getSystemInfo*(): JsonNode =
  result = %*{
    "compiled":           CompileDate & "T" & CompileTime,
    "NimVersion":         NimVersion,
    "hostCPU":            hostCPU,
    "hostOS":             hostOS,
    "cpuEndian":          cpuEndian,
    "getTempDir":         getTempDir(),
    "getFreeMem":         getFreeMem(),
    "getTotalMem":        getTotalMem(),
    "getOccupiedMem":     getOccupiedMem(),
    "countProcessors":    countProcessors(),
    "arch":               uname().machine,
    "FSCaseSensitive":    FileSystemCaseSensitive,
    "currentCompilerExe": getCurrentCompilerExe(),
    "nimpretty":          if findExe"choosenim".len > 0: execCmdEx("nimpretty --version").output.strip  else: "",
    "nimble":             if findExe"choosenim".len > 0: execCmdEx("nimble --noColor --version").output.strip else: "",
    "nimsuggest":         if findExe"choosenim".len > 0: execCmdEx("nimsuggest --version").output.strip else: "",
    "choosenim":          if findExe"choosenim".len > 0: execCmdEx("choosenim --noColor --version").output.strip else: "",
    "gcc":                if findExe"gcc".len > 0: execCmdEx("gcc --version").output.splitLines()[0].strip else: "",
    "clang":              if findExe"clang".len > 0: execCmdEx("clang --version").output.splitLines()[0].strip else: "",
    "git":                if findExe"git".len > 0: execCmdEx("git --version").output.replace("git version", "").strip else: "",
    "node":               if findExe"node".len > 0: execCmdEx("node --version").output.strip else: "",
    "python":             if findExe"python".len > 0: execCmdEx("python --version").output.replace("Python", "").strip else: "",
    "ssd":                isSsd()
  }
