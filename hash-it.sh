#!/usr/bin/env bash

PEPPER_FILE=.pepper

die() {
    echo "$(basename "$0"): $1" >&2
    exit $2
}

cmd_help() {
    echo "Hash and verify passwords

init - initialize
salt - gen salt
hash - read password from stdin and write hash and salt to stdout
verify - read password from stdin, receive hash from first argument and retuns result"
}

cmd_init() {
    test -e $PEPPER_FILE && die "Already initialized" 1
    date +%s%N | sha256sum | head -c 64 > $PEPPER_FILE
}

cmd_gen_salt() {
    date +%s%N | sha256sum | head -c 64
}

get_pepper() {
    cat $PEPPER_FILE
}

cmd_hash_password() {

    password=$(cat)
    salt="$(cmd_gen_salt)"
    pepper="$(get_pepper)"

    echo "$(echo $password$salt$pepper | sha256sum | awk '{printf $1}')$salt"
}

cmd_verify() {

    password=$(cat)
    pre_hash="$1"
    test -z "$pre_hash" && bye "No hash" 1
    salt="$(echo "$pre_hash" | tail -c 65)"
    pepper="$(get_pepper)"

    test "$1" = "$(echo $password$salt$pepper | sha256sum | awk '{printf $1}')$salt" && echo "Ok" || die "Validation failed" 1
}


case "$1" in
    init) shift;   cmd_init    "$@" ;;
    help) shift;   cmd_help    "$@" ;;
    salt) shift;   cmd_gen_salt "$@";;
    hash) shift;   cmd_hash_password "$@";;
    verify) shift; cmd_verify "$@";;

    *)             cmd_help "$@";;
esac
exit 0
