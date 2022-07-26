# BfE Technology DevOPs Skill Assessment
A Docker-based structure for local development containers for WordPress and PHP in VS Code with Nginx as web server designed for BfE Technology DevOPs Engineer position Skill Assessment by `John Ojebode` `<iamjohnricho@gmail.com>`.

## Usage

To get started, ensure you have [Docker installed](https://docs.docker.com/desktop/) for whatever operating system you are using, and then unzip/extract this `bfe-docker` project folder to a path of your choise on your device.

Next, navigate in your terminal to the directory you extracted this `bfe-docker` to, and spin up the containers for the web server by running `docker-compose up -d --build server`.

After that completes, follow the steps from the [bfe-docker/README.md](bfe-docker/README.md) file to get your WordPress installation added in (or create a new blank one).

You can then bring up the Docker Compose network with `server` instead of just using `up`, to ensures that only the server containers are brought up. The following are the web server configured, with the exposed ports detailed:

- **nginx** - `:80` on both host machine and the nginx container, accessible on `https://localhost`.
- **mysql** - `:3306` on both host machine and the mysql database container.
- **php** - `:9000`  for nginx proxy server in the nginx config file.
- **xdebug** - `:9001` on VS Code Xdebug configuration file.


## MySQL Storage

By default, whenever a docker network is brought down, MySQL data will be removed after the containers are destroyed. MySQL `mysql` directory has been added to persist data even after bringing containers down and back up, in the mysql folder isn't included, please do the following:

1. Create a `mysql` dictory in the `bfe-docker` project root directory.
2. Under the mysql service in the `docker-compose.yml` file, ensure the following lines are there:

```
volumes:
  - ./mysql:/var/lib/mysql
```


## Nginx Configuration

An `nginx` directory has been added for `nginx` web server block configuration and `nginx.conf` file must be created if not exist and must always contain the below server block configuration code in order for wordpress and nginx to stay linked:


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

## WordPress Directory

The `wordpress` directory in the `bfe-docker` project root directory contain the latest version of WordPress, this directory must always present in the root directory so as to be mapped to the nginx web directory so as to serve wordpress as the web project. If at anytime there is no file in the wordpress folder or its mistakenly deleted, do the following: 

- Spin up and built the docker network with `docker-compose up -d --build server`, then pull the files for a new WordPress installation by running `docker-compose run --rm wp core download` in your terminal to download fresh wordpress from docker repo.