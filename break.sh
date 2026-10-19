#!/bin/bash
# break.sh v2 - randomly ek (ya do) cheez todta hai. Tu dhoondh ke theek kar.
#
#   sudo ./break.sh          -> 1 cheez todega
#   sudo ./break.sh 2        -> 2 cheezein todega (mushkil mode)
#   sudo cat /root/.what-i-broke   -> SIRF fix karne ke BAAD dekhna
#
# Nayi galti mile toh neeche list mein khud jodna. Yahi is script ka asli faayda hai.

set -u
LOG=/root/.what-i-broke
WEBROOT=/usr/share/nginx/html
NGINX_CONF=/etc/nginx/nginx.conf
TOTAL=24

> $LOG

break_one () {
case $1 in

# ---------- SERVICE / PROCESS ----------
 1) systemctl stop nginx
    echo "1) nginx service stop kar di" >> $LOG ;;

 2) systemctl stop nginx; systemctl disable nginx >/dev/null 2>&1
    echo "2) nginx band + boot pe disable" >> $LOG ;;

 3) nohup sleep 99999 >/dev/null 2>&1 &
    for i in 1 2 3 4 5; do nohup dd if=/dev/zero of=/dev/null >/dev/null 2>&1 & done
    echo "3) 5 dummy process CPU kha rahe hain (dd)" >> $LOG ;;

 4) systemctl mask nginx >/dev/null 2>&1; systemctl stop nginx
    echo "4) nginx MASK kar di - start hi nahi hogi jab tak unmask na karo" >> $LOG ;;

# ---------- NGINX CONFIG ----------
 5) sed -i 's/listen       80/listen       8080/' $NGINX_CONF
    systemctl restart nginx 2>/dev/null
    echo "5) nginx ka port 80 -> 8080 (nginx.conf)" >> $LOG ;;

 6) echo "this is garbage {{{" >> $NGINX_CONF
    echo "6) nginx.conf ke end mein syntax error" >> $LOG ;;

 7) sed -i "s#root         /usr/share/nginx/html#root         /usr/share/nginx/wrong#" $NGINX_CONF
    systemctl restart nginx 2>/dev/null
    echo "7) nginx ka document root galat folder pe kar diya" >> $LOG ;;

 8) sed -i 's/index  index.html/index  home.html/' $NGINX_CONF
    systemctl restart nginx 2>/dev/null
    echo "8) default index file ka naam badal diya (index.html -> home.html)" >> $LOG ;;

# ---------- PERMISSIONS / OWNERSHIP ----------
 9) chmod 000 $WEBROOT/index.html
    echo "9) index.html permission 000" >> $LOG ;;

10) chown -R nobody:nobody $WEBROOT
    echo "10) webroot ka owner nobody:nobody" >> $LOG ;;

11) chmod 000 $WEBROOT
    echo "11) webroot folder ki permission 000 (folder khud nahi khulega)" >> $LOG ;;

12) chmod 600 /etc/nginx/nginx.conf; chown nobody /etc/nginx/nginx.conf
    echo "12) nginx.conf ka owner/permission bigaad diya" >> $LOG ;;

# ---------- FILES ----------
13) mv $WEBROOT/index.html $WEBROOT/index.html.bak
    echo "13) index.html ka naam badal diya (.bak)" >> $LOG ;;

14) truncate -s 0 $WEBROOT/index.html
    echo "14) index.html khaali kar di (0 bytes)" >> $LOG ;;

# ---------- DISK ----------
15) fallocate -l 3G /var/log/bigfile.log 2>/dev/null || dd if=/dev/zero of=/var/log/bigfile.log bs=1M count=3000 2>/dev/null
    echo "15) /var/log/bigfile.log se disk bhari (delete karna: rm /var/log/bigfile.log)" >> $LOG ;;

16) for i in $(seq 1 60000); do : > /tmp/f$i; done
    echo "16) /tmp mein 60000 khaali files - INODES bhar diye (df -h theek dikhega, df -i nahi)" >> $LOG ;;

# ---------- NETWORK / FIREWALL ----------
17) iptables -A INPUT -p tcp --dport 80 -j DROP 2>/dev/null
    echo "17) iptables se port 80 DROP kar diya (localhost se chalega, bahar se nahi)" >> $LOG ;;

18) iptables -A OUTPUT -p tcp --dport 443 -j REJECT 2>/dev/null
    echo "18) outgoing 443 band - yum/dnf aur curl https fail honge" >> $LOG ;;

19) nohup python3 -m http.server 80 >/dev/null 2>&1 &
    sleep 1; systemctl restart nginx 2>/dev/null
    echo "19) doosra process port 80 pe baith gaya - nginx bind nahi kar paayegi" >> $LOG ;;

# ---------- DNS ----------
20) echo "127.0.0.1 aryancode.in" >> /etc/hosts
    echo "20) /etc/hosts mein galat entry - domain localhost pe ja raha hai" >> $LOG ;;

21) cp /etc/resolv.conf /etc/resolv.conf.bak; echo "nameserver 10.255.255.1" > /etc/resolv.conf
    echo "21) resolv.conf mein nakli DNS server - naam resolve hi nahi honge" >> $LOG ;;

# ---------- USERS / CRON / SYSTEMD ----------
22) usermod -s /sbin/nologin ec2-user 2>/dev/null
    echo "22) ec2-user ka shell nologin kar diya (naya SSH login fail hoga)" >> $LOG ;;

23) echo "* * * * * root rm -f $WEBROOT/index.html" > /etc/cron.d/sabotage
    echo "23) cron job har minute index.html delete kar raha hai (/etc/cron.d/sabotage)" >> $LOG ;;

24) systemctl stop crond 2>/dev/null; systemctl disable crond >/dev/null 2>&1
    echo "24) crond band - saare scheduled jobs ruk gaye" >> $LOG ;;

esac
}

COUNT=${1:-1}
used=""
for n in $(seq 1 "$COUNT"); do
  while :; do
    p=$(( RANDOM % TOTAL + 1 ))
    case " $used " in *" $p "*) continue ;; esac
    used="$used $p"; break
  done
  break_one "$p"
done

chmod 600 $LOG
echo "Kuch tod diya. Ab dhoondh."
