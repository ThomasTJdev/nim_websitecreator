## Static string Bash Commands constants, do NOT put any run-time logic here, only consts.
## Ignore line lenght on this file.


when defined(db_postgres):
  const fileBackup* = "nimwc_postgres_"
  const cmdBackup* = "pg_dump --verbose --no-password --encoding=UTF8 --lock-wait-timeout=99 --host=$1 --port=$2 --username=$3 --file='$4' --dbname=$5 $6 "
else:
  const fileBackup* = "nimwc_sqlite_"
  const cmdBackup* = "sqlite3 -readonly -echo $1 '.backup $2' "


const
  cmdStrip* = "strip --strip-all --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag"           # Defined statically on nimwc.nim.cfg,

  cmdSign* = "gpg --armor --detach-sign --yes --digest-algo sha512 "

  cmdChecksum* = "sha512sum --tag "

  cmdTar* = "tar cafv "
