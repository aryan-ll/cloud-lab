#!/bin/bash
echo "== nginx install =="
sudo dnf install nginx -y

echo "== service chalu =="
sudo systemctl enable --now nginx

echo "== page daal rahe hain =="
echo "<h1>cloud-lab</h1><p>setup.sh se bana</p>" | sudo tee /usr/share/nginx/html/index.html

echo "== check =="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost
