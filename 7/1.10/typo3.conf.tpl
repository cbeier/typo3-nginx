server {
    server_name {{ getenv "NGINX_SERVER_NAME" "typo3" }};
    listen 80;

    root {{ getenv "NGINX_SERVER_ROOT" "/var/www/html/" }};
    index index.php;

    fastcgi_keep_conn on;
    fastcgi_index index.php;
    fastcgi_param QUERY_STRING $query_string;
    fastcgi_param SCRIPT_NAME $fastcgi_script_name;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

    add_header Cache-Control "store, must-revalidate, post-check=0, pre-check=0";

    location ~* ^/.well-known/ {
        allow all;
    }

    location = /favicon.ico {
        try_files $uri =204;
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location = /readme.html {
        return 404;
    }

    location ~* ^.*(\.(?:git|svn|htaccess|txt|pot?))$ {
        return 404;
    }

    location ~ /\. {
        deny all;
    }

    location ~* .*\.(?:m4a|mp4|mov)$ {
        mp4;
        mp4_buffer_size     1M;
        mp4_max_buffer_size 5M;
    }

    location ~* ^.+\.(?:ogg|pdf|pptx?)$ {
        expires max;
        tcp_nodelay off;
    }

    if (!-e $request_filename){
        rewrite ^/(.+)\.(\d+)\.(php|js|css|png|jpg|gif|gzip)$ /$1.$3 last;
    }

    location ~* ^/fileadmin/(.*/)?_recycler_/ {
        deny all;
    }
    location ~* ^/fileadmin/templates/.*(\.txt|\.ts)$ {
        deny all;
    }
    location ~* ^/typo3conf/ext/[^/]+/Resources/Private/ {
        deny all;
    }
    location ~* ^/(typo3/|fileadmin/|typo3conf/|typo3temp/|uploads/|favicon\.ico) {
    }

    location / {
        if ($query_string ~ ".+") {
            return 405;
        }
        if ($http_cookie ~ 'nc_staticfilecache|be_typo_user|fe_typo_user' ) {
            return 405;
        } # pass POST requests to PHP
        if ($request_method !~ ^(GET|HEAD)$ ) {
            return 405;
        }
        if ($http_pragma = 'no-cache') {
            return 405;
        }
        if ($http_cache_control = 'no-cache') {
            return 405;
        }
        error_page 405 = @nocache;

        try_files /typo3temp/tx_ncstaticfilecache/$host${request_uri}index.html @nocache;
    }

    # Directives to send expires headers and turn off 404 error logging.
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|woff2|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
        access_log off; log_not_found off; expires max;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }

        include fastcgi.conf;
        fastcgi_index index.php;
        fastcgi_pass backend;
        track_uploads uploads 60s;
    }
}
