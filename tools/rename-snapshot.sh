for dir in Backup_*; do
    # aquí $dir toma cada nombre que empieza con 'Backup_'
    if [ -d "$dir" ]; then   # verificamos que sea un directorio
        mv "$dir" "Snapshot_${dir#Backup_}"  # renombramos
    fi
done

