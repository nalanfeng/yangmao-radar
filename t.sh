#!/bin/bash
# one-shot: open a tmate session fully detached, write ssh line to ~/ssh.txt
cd ~
[ -x ~/tmate-2.4.0-static-linux-amd64/tmate ] || { curl -fsSL -o tmate.tar.xz https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz && tar xJf tmate.tar.xz; }
rm -f ~/ssh.txt
nohup setsid bash -c 'T=$HOME/tmate-2.4.0-static-linux-amd64/tmate; $T -S /tmp/h3.sock new-session -d; $T -S /tmp/h3.sock wait tmate-ready; $T -S /tmp/h3.sock display -p "#{tmate_ssh}" > $HOME/ssh.txt' </dev/null >/dev/null 2>&1 &
echo STARTED
