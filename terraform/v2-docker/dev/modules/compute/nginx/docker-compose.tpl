version: '3.8'

services:
  app:
    image: ${image}
    container_name: ${container_name}
    restart: always
    expose:
      - "${port}"

  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - ${container_name}

