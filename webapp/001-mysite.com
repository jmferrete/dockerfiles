server {
	listen 80 default_server;
	listen [::]:80 default_server ipv6only=on;

	root /var/www/php/mysite.com;
	index index.php;

	server_name mysite.com www.mysite.com;

	client_max_body_size 100m;

	location / {
		try_files $uri $uri/ =404;
	}

	location ^~ /admin/ {
		auth_basic "Restricted";
		auth_basic_user_file /etc/nginx/.htpasswd;

		location ~ \.php$ {

			# Setup var defaults
			set $no_cache "";
			# If non GET/HEAD, don't cache & mark user as uncacheable for 1 second via cookie
			if ($request_method !~ ^(GET|HEAD)$) {
				set $no_cache "1";
			}
			# Drop no cache cookie if need be
			# (for some reason, add_header fails if included in prior if-block)
			if ($no_cache = "1") {
				add_header Set-Cookie "_mcnc=1; Max-Age=2; Path=/";
				add_header X-Microcachable "0";
			}
			# Bypass cache if no-cache cookie is set
			if ($http_cookie ~* "_mcnc") {
						set $no_cache "1";
			}
			# Bypass cache if flag is set
			fastcgi_no_cache $no_cache;
			fastcgi_cache_bypass $no_cache;
			fastcgi_cache microcache;
			fastcgi_cache_key $scheme$host$request_uri$request_method;
			fastcgi_cache_valid 200 301 302 10m;
			fastcgi_cache_use_stale updating error timeout invalid_header http_500;
			fastcgi_pass_header Set-Cookie;
			fastcgi_pass_header Cookie;
			fastcgi_ignore_headers Cache-Control Expires Set-Cookie;

			fastcgi_buffer_size 128k;
			fastcgi_buffers 256 16k;
			fastcgi_busy_buffers_size 256k;
			fastcgi_temp_file_write_size 256k;
			fastcgi_read_timeout 240;

			try_files $uri =404;
			include /etc/nginx/fastcgi_params;
			##fastcgi_pass 127.0.0.1:9000;
			fastcgi_pass unix:/var/run/php5-fpm.sock;
			fastcgi_index index.php;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			fastcgi_param PATH_INFO $fastcgi_script_name;
			fastcgi_intercept_errors on;

			# Memcache full page store

			set $no_cache "";
			if ($query_string ~ ".+") {
				set $no_cache "1";
			}
			if ($request_method !~ ^(GET|HEAD)$ ) {
				set $no_cache "1";
			}
			if ($request_uri ~ "nocache") {
				set $no_cache "1";
			}
			if ($no_cache = "1") {
				return 405;
			}

			set $memcached_key $host$request_uri;
			memcached_pass 127.0.0.1:11211;
			default_type text/html;
			error_page 404 405 502 = @php;
			expires epoch;
		}
	}

	location /phpmyadmin {
		auth_basic "Restricted";
		auth_basic_user_file /etc/nginx/.htpasswd;
	}

	# Only for nginx-naxsi used with nginx-naxsi-ui : process denied requests
	#location /RequestDenied {
	#	proxy_pass http://127.0.0.1:8080;    
	#}

	#error_page 404 /404.html;

	# redirect server error pages to the static page /50x.html
	#
	#error_page 500 502 503 504 /50x.html;
	#location = /50x.html {
	#	root /usr/share/nginx/html;
	#}

	location ~ \.php$ {

		# Setup var defaults
		set $no_cache "";
		# If non GET/HEAD, don't cache & mark user as uncacheable for 1 second via cookie
		if ($request_method !~ ^(GET|HEAD)$) {
			set $no_cache "1";
		}
		# Drop no cache cookie if need be
		# (for some reason, add_header fails if included in prior if-block)
		if ($no_cache = "1") {
			add_header Set-Cookie "_mcnc=1; Max-Age=2; Path=/";
			add_header X-Microcachable "0";
		}
		# Bypass cache if no-cache cookie is set
		if ($http_cookie ~* "_mcnc") {
					set $no_cache "1";
		}
		# Bypass cache if flag is set
		fastcgi_no_cache $no_cache;
		fastcgi_cache_bypass $no_cache;
		fastcgi_cache microcache;
		fastcgi_cache_key $scheme$host$request_uri$request_method;
		fastcgi_cache_valid 200 301 302 10m;
		fastcgi_cache_use_stale updating error timeout invalid_header http_500;
		fastcgi_pass_header Set-Cookie;
		fastcgi_pass_header Cookie;
		fastcgi_ignore_headers Cache-Control Expires Set-Cookie;

		fastcgi_buffer_size 128k;
		fastcgi_buffers 256 16k;
		fastcgi_busy_buffers_size 256k;
		fastcgi_temp_file_write_size 256k;
		fastcgi_read_timeout 240;

		try_files $uri =404;
		include /etc/nginx/fastcgi_params;
		##fastcgi_pass 127.0.0.1:9000;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_script_name;
		fastcgi_intercept_errors on;

		# Memcache full page store

		set $no_cache "";
		if ($query_string ~ ".+") {
			set $no_cache "1";
		}
		if ($request_method !~ ^(GET|HEAD)$ ) {
			set $no_cache "1";
		}
		if ($request_uri ~ "nocache") {
			set $no_cache "1";
		}
		if ($no_cache = "1") {
			return 405;
		}

		set $memcached_key $host$request_uri;
		memcached_pass 127.0.0.1:11211;
		default_type text/html;
		error_page 404 405 502 = @php;
		expires epoch;

	}

	location @php {
		
		try_files $uri =404;
		include /etc/nginx/fastcgi_params;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_script_name;
		fastcgi_intercept_errors on;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}

	location ~*  \.(jpg|jpeg|png|gif|ico)$ {
		expires 365d;
	}

	location ~*  \.(jpg|jpeg|png|gif|ico)$ {
		log_not_found on;
		access_log off;
	}

}


