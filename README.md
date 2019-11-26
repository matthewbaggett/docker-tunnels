# Docker Service Tunnels
Containers that create SSH tunnels to various services, to be used with a bastion ssh server.

Based on the work of Cagatay Gurturk: https://github.com/cagataygurturk/docker-ssh-tunnel

The major differences are that the `tunnel:mysql` and `tunnel:redis` images have healthchecks for the connection.

## Usage:
First, make sure your bastion ssh server is configured correctly in your `~/.ssh/config`:
```
Host bastion # You can use any name
    HostName bastion.example.com 
    IdentityFile ~/.ssh/id_rsa # Private key location
    User YourName # Username to connect to SSH service
    ForwardAgent yes
    TCPKeepAlive yes
    ConnectTimeout 5
    ServerAliveCountMax 10
    ServerAliveInterval 15
```
Its probably a good idea to check that you can use this new connection: `ssh bastion`

Then we can configure our `docker-compose.yml`: 
```yaml
  mysql:
    image: matthewbaggett/tunnel:mysql
    volumes:
      - $HOME/.ssh:/root/ssh:ro
    environment:
      TUNNEL_HOST: bastion
      REMOTE_HOST: mysql.example.com
      LOCAL_PORT: 3306
      REMOTE_PORT: 3306
      MYSQL_USER: username
      MYSQL_PASSWORD: changeme
    ports:
      - '3306:3306'

  redis:
    image: matthewbaggett/tunnel:redis
    volumes:
      - $HOME/.ssh:/root/ssh:ro
    environment:
      TUNNEL_HOST: bastion
      REMOTE_HOST: redis.example.com
      LOCAL_PORT: 6379
      REMOTE_PORT: 6379
    ports:
      - '6379:6379'
```