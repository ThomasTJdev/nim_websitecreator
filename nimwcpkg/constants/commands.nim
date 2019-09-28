## Static string Bash Commands constants, do NOT put any run-time logic here, only consts.
## Ignore line lenght on this file.
## Do NOT import this file directly, instead import ``constants.nim``


const
  cmdStrip* = "strip --strip-all --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag"           # Defined statically on nimwc.nim.cfg,

  cmdSign* = "gpg --armor --detach-sign --yes --digest-algo sha512 "

  cmdChecksum* = "sha512sum --tag "

  cmdTar* = "tar cafv "

  cmdBackup* =
    when defined(db_postgres): "pg_dump --verbose --no-password --encoding=UTF8 --lock-wait-timeout=99 --host=$1 --port=$2 --username=$3 --file='$4' --dbname=$5 $6 "
    else: "sqlite3 -readonly -echo $1 '.backup $2' "
