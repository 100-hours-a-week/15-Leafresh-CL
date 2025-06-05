server {
    listen 443 ssl;
    server_name ${domain};

    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://app:${port};
        # proxy_pass http://localhost:${port};
        proxy_http_version 1.1;
        proxy_set_header Host \u0024host;
        proxy_set_header X-Real-IP \u0024remote_addr;
        proxy_set_header X-Forwarded-For \u0024proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \u0024scheme;
    }
}

server {
    listen 80;
    server_name ${domain};

    # HTTP 요청을 HTTPS로 리디렉션
    return 301 https://$host$request_uri;
}
