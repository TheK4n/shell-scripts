
bkp_dir_1=~/Backup/1/$(date +"%d-%m-%y")
bkp_dir_2=~/Backup/2/$(date +"%d-%m-%y")
cur_dir_name="$(basename "$PWD")"

mkdir -p "$bkp_dir_1" || true
mkdir -p "$bkp_dir_2" || true
tar czf - * | gpg -e -R thek4n > "$bkp_dir_1"/"$cur_dir_name".tar.gz.gpg
cp "$bkp_dir_1"/"$cur_dir_name".tar.gz.gpg "$bkp_dir_2"/"$cur_dir_name".tar.gz.gpg
