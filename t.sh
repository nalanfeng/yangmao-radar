#!/bin/bash
cd ~
L=/tmp/t.log; : > $L
[ -x ~/tmate-2.4.0-static-linux-amd64/tmate ] || { curl -fsSL -o tmate.tar.xz https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz && tar xJf tmate.tar.xz; }
cat > /tmp/inner.sh <<'IN'
L=/tmp/t.log
T=$HOME/tmate-2.4.0-static-linux-amd64/tmate; S=/tmp/h5.sock
(timeout 5 bash -c '</dev/tcp/sgp1.tmate.io/22' && echo P22OK || echo P22FAIL) >>$L 2>&1
(timeout 5 bash -c '</dev/tcp/ssh.tmate.io/22' && echo SSH22OK || echo SSH22FAIL) >>$L 2>&1
echo "whoami=$(whoami) tty=$(tty 2>&1)" >>$L
TERM=xterm $T -S $S new-session -d >>$L 2>&1; echo "new rc=$?" >>$L
timeout 40 $T -S $S wait tmate-ready >>$L 2>&1; echo "wait rc=$?" >>$L
echo "SSH=> $($T -S $S display -p '#{tmate_ssh}' 2>&1)" >>$L
IN
nohup setsid bash /tmp/inner.sh </dev/null >/dev/null 2>&1 &
echo STARTED
