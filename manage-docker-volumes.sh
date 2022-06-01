#!/usr/bin/env bash


die() {
    echo "$(basename "$0"): $1" >&2
    exit $2
}

cmd_help() {
    echo "Hash and verify passwords

backup <container> - backup, compress volume of container and put it into ./docker_backups/
restore <container> <volume-backup-path> - restore volume"
}

cmd_backup() {
    test -z "$1" && die "No container name" 1

    BACKUP_DIR="$(pwd)/docker_backups"
    mkdir $BACKUP_DIR || true

    container="$1"

    DATE=`date '+%d-%m-%Y--%H-%M-%S'`

    mount_points=$(docker inspect --format='{{range $p, $conf := .Mounts}}{{$conf.Destination}} {{end}}' $container)

    i=1
    for mp in $mount_points
    do
        BACKUP_NAME="${container}_${DATE}_volume_backup_${i}.tar.gz"
        docker run --rm --volumes-from "$container" -v "$BACKUP_DIR":/backup busybox tar czf /backup/"$BACKUP_NAME" "$mp"
        i=$((i + 1))
    done 
}

cmd_restore() {
    test -z "$1" && die "No container name" 1
    test -z "$2" && die "No backup path" 1

    container="$1"
    BACKUP_NAME="$2"

    docker run --rm --volumes-from "$container" -v "$(pwd)":/backup busybox tar xzf /backup/"$BACKUP_NAME"
}


case "$1" in
    backup) shift;   cmd_backup    "$@" ;;
    help) shift;   cmd_help    "$@" ;;
    restore) shift;   cmd_restore "$@";;

    *)             cmd_help "$@";;
esac
exit 0
