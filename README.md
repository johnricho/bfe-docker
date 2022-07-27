# BfE Technology DevOPs Skill Assessment
A Docker-based structure for local development containers for WordPress and PHP in VS Code with Nginx as web server designed for BfE Technology DevOPs Engineer position Skill Assessment by `John Ojebode` `<iamjohnricho@gmail.com>`.

## Docker

Docker is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers.

### Setup

- Download and install [Docker](https://docs.docker.com/desktop/) on your local machine.
- Unzip/extract the `bfe-docker` project folder to a path on your machine.
- Navigate in your terminal to the directory you extracted the `bfe-docker` 
- Spin up the containers for the web server by running `docker-compose up -d --build server`.

You can then bring up the Docker Compose network with `server` instead of just using `up`, to ensures that only the server containers are brought up. 

#### Web server configuration with the ports exposed:

- **nginx** - `:80` on both host machine and the nginx container, accessible on `https://localhost`.
- **mysql** - `:3306` on both host machine and the mysql database container.
- **php** - `:9000`  for nginx proxy server in the nginx config file.
- **xdebug** - `:9001` on VS Code Xdebug configuration file and on container.

## Nginx

NGINX is a free, open-source, high-performance HTTP server and reverse proxy, as well as an IMAP/POP3 proxy server. 

### Setup

Server block configuration:

```
server {
    listen 80;
    listen [::]:80;

    server_name localhost localhost.io www.localhost.io;

    index index.php index.html index.htm;

    root /var/www/html;

    location ~ /.well-known/acme-challenge {
        allow all;
        root /var/www/html;
    }

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wp:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
    
    location = /favicon.ico { 
        log_not_found off; access_log off; 
    }
    location = /robots.txt { 
        log_not_found off; access_log off; allow all; 
    }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }
}

```

The `server_name` in the server configuration block can be replaced with your custom test domain or IP address.

## WordPress

WordPress is a free and open-source content management system written in PHP and paired with a MySQL or MariaDB database

### Setup

- Spin up and built the docker network with `docker-compose up -d --build server`, 
- Pull WordPress installation by running `docker-compose run --rm wp core download` in your terminal to download fresh wordpress from docker repo.


## MySQL

MySQL is an open-source relational database management system.

### Data Persistent Setup

1. Create a `mysql` dictory in the `bfe-docker` project root directory.
2. Mount the `mysql` in the docker container to the mysql directory in the `bfe-docker` for data persistence.
3. Add the below lines to the `db` service in the `docker-compose.yml` file:

```
volumes:
  - ./mysql:/var/lib/mysql
```


## XDebug

Xdebug is a debugging extension for PHP.

### Setup

- Install VSCode and the `PHP Debug` extension by `Felix Becker`.
- Ensure the `launch.json` file in .vscode directory contain the following:

    ```
    {
        "version": "3.0.0beta1",
        "configurations": [
            {
                "name": "Listen for Xdebug",
                "type": "php",
                "request": "launch",
                "port": 9002
            },
            {
                "name": "Listen on Docker for Xdebug",
                "type": "php",
                "request": "launch",
                "port": 9001,
                "pathMappings": {
                    "/var/www/html/": "${workspaceFolder}"
                }
            }
        ]
    }
    ```


### Usage

- Click the Debug icon in the left sidebar. At the top of the sidebar, you should see the debug options. 
- Select the ‘Listen on Docker for Xdebug’ option, then click the play green button beside it.
- Test your application on browser. In the editor, you will see script execution stop at your breakpoint.
- Inspect all breakpoints, the call stack, SuperGlobals, constants and more.