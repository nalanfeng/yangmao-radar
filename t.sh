#!/bin/bash
cd ~
[ -x ~/tmate-2.4.0-static-linux-amd64/tmate ] || { curl -fsSL -o tmate.tar.xz https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz && tar xJf tmate.tar.xz; }
T=~/tmate-2.4.0-static-linux-amd64/tmate
S=/tmp/h4.sock
if ! $T -S $S display -p '#{tmate_ssh}' </dev/null >/dev/null 2>&1; then
  $T -S $S new-session -d </dev/null >/tmp/tmate.out 2>&1
fi
timeout 40 $T -S $S wait tmate-ready </dev/null >>/tmp/tmate.out 2>&1
R=$(timeout 10 $T -S $S display -p '#{tmate_ssh}' </dev/null 2>&1)
echo "SSH=> $R"
[ -z "$R" ] && { echo LOG:; tail -5 /tmp/tmate.out; ls -la $S 2>&1; }
