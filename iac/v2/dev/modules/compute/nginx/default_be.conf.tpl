server {
    listen 443 ssl;
    server_name ${domain};

    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://app:${port};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # CORS 헤더 추가
        # add_header 'Access-Control-Allow-Origin' 'http://localhost:3000' always;
        # add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        # add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
        # add_header 'Access-Control-Allow-Credentials' 'true' always;

        # OPTIONS 사전 요청 처리
        # if ($request_method = 'OPTIONS') {
        #     add_header 'Access-Control-Max-Age' 1728000;
        #     add_header 'Content-Type' 'text/plain; charset=utf-8';
        #     add_header 'Content-Length' 0;
        #     return 204;
        # }
    }
}

server {
    listen 80;
    server_name ${domain};

    # HTTP 요청을 HTTPS로 리디렉션
    return 301 https://\$host\$request_uri;
}
