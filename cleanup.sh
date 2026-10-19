#!/bin/bash
# cleanup.sh - break.sh ka saara kachra saaf karta hai aur sab wapas normal.
# Chalao:  sudo ./cleanup.sh
#
# Isko SIRF tab chalana jab ulajh jao ya din khatam ho.
# Har baar chalaoge toh practice ka matlab hi khatam - pehle KHUD dhoondho.

set -u
WEBROOT=/usr/share/nginx/html

echo "-- disk ka kachra"
rm -f /var/log/bigfile.log
rm -f /tmp/f* 2>/dev/null

echo "-- iptables rules"
iptables -F 2>/dev/null

echo "-- port 80 pe baitha python process"
pkill -f "http.server" 2>/dev/null
pkill -f "dd if=/dev/zero" 2>/dev/null

echo "-- DNS"
sed -i '/aryancode.in/d' /etc/hosts
[ -f /etc/resolv.conf.bak ] && mv /etc/resolv.conf.bak /etc/resolv.conf

echo "-- cron sabotage"
rm -f /etc/cron.d/sabotage
systemctl enable --now crond >/dev/null 2>&1

echo "-- user shell"
usermod -s /bin/bash ec2-user 2>/dev/null

echo "-- web files"
[ -f $WEBROOT/index.html.bak ] && mv $WEBROOT/index.html.bak $WEBROOT/index.html
[ -s $WEBROOT/index.html ] || echo "<h1>cloud-lab</h1>" > $WEBROOT/index.html
chmod 755 $WEBROOT
chmod 644 $WEBROOT/index.html
chown -R root:root $WEBROOT

echo "-- nginx config wapas default"
chown root:root /etc/nginx/nginx.conf
chmod 644 /etc/nginx/nginx.conf
sed -i 's/listen       8080/listen       80/' /etc/nginx/nginx.conf
sed -i 's/index  home.html/index  index.html/' /etc/nginx/nginx.conf
sed -i "s#root         /usr/share/nginx/wrong#root         /usr/share/nginx/html#" /etc/nginx/nginx.conf
sed -i '/this is garbage/d' /etc/nginx/nginx.conf

echo "-- nginx wapas chalu"
systemctl unmask nginx >/dev/null 2>&1
systemctl enable --now nginx >/dev/null 2>&1
systemctl restart nginx

echo
nginx -t && systemctl is-active nginx
curl -s -o /dev/null -w "localhost -> HTTP %{http_code}\n" http://localhost
rm -f /root/.what-i-broke
echo "Sab saaf. Wapas normal."
