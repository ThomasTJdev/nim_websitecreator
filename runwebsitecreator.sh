until ./websitecreator; do
    echo "Manager crashed with exit code $?.  Respawning.." >&2
    echo "Manager crashed with exit code $?.  Respawning.." >&2 >> log/log.log
    sleep 1
done