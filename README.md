## 2026-10-23 nginx config broken, website still 200 OK
- Symptom: website worked, but nothing looked wrong
- How I found it: `sudo nginx -t` showed `unknown directive "this" in nginx.conf:83`
- Cause: a garbage line at the end of /etc/nginx/nginx.conf
- Fix: removed the line (`sudo sed -i '$d' /etc/nginx/nginx.conf`), then `sudo nginx -t` and `sudo systemctl reload nginx`
- Lesson: a running nginx hides a broken config. It fails on the next restart. Always run `nginx -t` after editing the config.


## 2026-10-19 Server slow, website returns 200 OK
- Symptom: website works, but server is slow (high load average)
- How I found it: `top` showed 5 `dd` processes using ~40% CPU each
- Fix: `sudo pkill dd`
- Lesson: if a server is slow, run `top` first
