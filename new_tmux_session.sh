#!/usr/bin/env bash

dir_="playground/new_dir"

mkdir -p $dir_ || true
tmux new-session -s test -d -c $dir_
tmux split-window -h -t test:0.0
tmux split-window -v -t test:0.1
tmux resize-pane -t test:0.0 -x 82
tmux resize-pane -t test:0.1 -x 20
tmux send-keys -t test:0.0 "cd $dir_" Enter

tmux send-keys -t test:0.0 "create-project -q TestProject" Enter
tmux send-keys -t test:0.0 "cd TestProject" Enter
tmux send-keys -t test:0.0 vim Enter
tmux send-keys -t test:0.2 "cd $dir_" Enter
tmux send-keys -t test:0.1 "cd $dir_/TestProject" Enter
tmux send-keys -t test:0.1 "va" Enter
tmux send-keys -t test:0.2 htop Enter

