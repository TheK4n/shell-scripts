#!/usr/bin/env bash

PEPPER_FILE="$HOME/.local/state/hash-it/pepper"
ROUNDS=$((2 ** 8))
_SALT_LEN=64

die() {
    echo "$(basename "$0"): $1" >&2
    exit $2
}

cmd_help() {
    echo "Hash and verify passwords

init - initialize
salt - gen salt
hash - read password from stdin and write hash and salt to stdout
check - read password:hash from stdin retuns result"
}


cmd_gen_salt() {
    dd if=/dev/urandom bs=256 count=16 2>/dev/null | sha256sum | head -c $_SALT_LEN
}

cmd_init() {
    test -e $PEPPER_FILE && die "Already initialized" 1
    umask 0077  # -rw-------
    mkdir -p "$(dirname "$PEPPER_FILE")"
    cmd_gen_salt > $PEPPER_FILE
}

get_pepper() {
    cat $PEPPER_FILE
}

recursive_prehash() {
    password=$1
    salt=$2
    pepper=$3
    pre_hash=$password$salt$pepper
    for (( i = 0; i < $ROUNDS; i++ )); do
        pre_hash="$(echo $pre_hash$salt$pepper | sha512sum | head -c 128)"
    done
    echo $pre_hash
}

cmd_hash_password() {
    test -e $PEPPER_FILE || die "Not initialized" 1

    password="$(cat)"
    salt="$(cmd_gen_salt)"
    pepper="$(get_pepper)"

    pre_hash=$(recursive_prehash $password $salt $pepper)

    echo "$pre_hash$salt"
}

cmd_verify() {
    test -e $PEPPER_FILE || die "Not initialized" 1

    password_hash="$(cat)"
    password="$(echo $password_hash | awk -F ':' '{printf $1}')"
    prev_hash="$(echo $password_hash | awk -F ':' '{printf $2}')"
    test -z "$password" && die "No password (password:hash)" 1
    test -z "$prev_hash" && die "No hash (password:hash)" 1

    salt="$(echo "$prev_hash" | tail -c $(($_SALT_LEN + 1)))"
    pepper="$(get_pepper)"

    pre_hash=$(recursive_prehash $password $salt $pepper)

    test "$prev_hash" = "$pre_hash$salt" && echo "OK" || die "Validation failed" 1
}


case "$1" in
    init) shift;   cmd_init    "$@" ;;
    salt) shift;   cmd_gen_salt "$@";;
    hash) shift;   cmd_hash_password "$@";;
    check) shift;  cmd_verify "$@";;

    *)             cmd_help "$@";;
esac
exit 0
