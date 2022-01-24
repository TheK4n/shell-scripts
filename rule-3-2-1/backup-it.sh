
bkp_dir_1=~/Backup/1/$(date +"%d-%m-%y")
cur_dir_name="$(basename "$PWD")"

mkdir -p ~/Backup/{1..2}/$(date +"%d-%m-%y")
tar czf - * | gpg -e -R thek4n > "$bkp_dir_1"/"$cur_dir_name".tar.gz.gpg
cp "$bkp_dir_1"/"$cur_dir_name".tar.gz.gpg "$bkp_dir_2"
