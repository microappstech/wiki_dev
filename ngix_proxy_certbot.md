# Create file domain name 
sudo nano /etc/nginx/sites-available/git.mouddakir.dev
## file content 
```
server {
    listen 80;
    server_name git.mouddakir.dev;

    client_max_body_size 512m;

    location / {
        proxy_pass http://127.0.0.1:8080;

        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_http_version 1.1;
        proxy_read_timeout 3600;
    }
}
```

## enable it 
```
sudo ln -s /etc/nginx/sites-available/git.mouddakir.dev /etc/nginx/sites-enabled/
```
```
sudo nginx -t
```
```
sudo systemctl reload nginx
```
## configure https
```
sudo certbot --nginx -d git.mouddakir.dev
```
