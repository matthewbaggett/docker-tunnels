FROM alpine:3.2 AS socket-tunnel

RUN apk add --no-cache openssh-client bash

CMD rm -rf /root/.ssh && mkdir /root/.ssh && cp -R /root/ssh/* /root/.ssh/ && chmod -R 600 /root/.ssh/* && \
ssh \
-o StrictHostKeyChecking=no \
-N $TUNNEL_HOST \
-L *:$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT \
&& while true; do sleep 30; done;

FROM socket-tunnel AS mysql-tunnel
HEALTHCHECK --interval=10s --timeout=3s \
  CMD mysqladmin ping \
    --silent \
    -h127.0.0.1 \
    -P$LOCAL_PORT \
    -u$MYSQL_USER \
    -p$MYSQL_PASSWORD
RUN apk add --no-cache mysql-client
EXPOSE 3306

FROM socket-tunnel AS redis-tunnel
HEALTHCHECK --interval=10s --timeout=3s \
  CMD redis-cli PING
RUN apk add --no-cache redis
EXPOSE 6379
