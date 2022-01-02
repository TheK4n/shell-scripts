cd "$1"

git fetch origin
diffs="$(git diff origin/main)" 

if [ -n "$diffs" ] 
then
    git pull
    docker-compose down
    docker-compose up -d --build
fi
