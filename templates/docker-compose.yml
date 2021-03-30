version: '3.5'
services:
  postgres:
    image: "${image}"
    restart: always
    network_mode: "host"
    volumes:
      - "/data:/data"
      - "/opt/postgres/pg.key:/opt/pg.key"
      - "/opt/postgres/pg.pem:/opt/pg.pem"
%{ if params != "" ~}
    command: ${params}
%{ endif ~}
    environment:
      PGDATA: /data
      POSTGRES_USER:     "${user}"
      POSTGRES_PASSWORD: "${password}"
      POSTGRES_DB:       "${database}"