version: '3.8'

services:
  frontend:
    image: jchanho99/frontend-dev:latest
    container_name: nextjs
    restart: always
    expose:
      - "3000"

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
      - frontend
