class component::php_vhost (
  $path = hiera('path', '/var/www/app_name'),
  $vhost = hiera('vhost', 'app-name.dev'),
  $env = hiera('env', 'dev'),
) {

  case $profile::webserver::type {
    nginx: {
      ## create default vhost
      nginx::resource::vhost { $vhost:
        ensure   => present,
        www_root => $path,
      }
      ## create location to direct .php to the fpm pool
      nginx::resource::location { 'wasted-php-rewrite':
        location  => '~ \.php$',
        vhost     => $vhost,
        fastcgi   => '127.0.0.1:9000',
        try_files => ['$uri =404'],
        www_root  => $path,
      }

      if defined(Class['::hhvm']) {
        ## create default vhost
        nginx::resource::vhost { "hhvm.${vhost}":
          ensure   => present,
          www_root => $path,
        }
        ## create location to direct .php to the fpm pool
        nginx::resource::location { 'hhvm-wasted-php-rewrite':
          location  => '~ \.php$',
          vhost     => "hhvm.${vhost}",
          fastcgi   => '127.0.0.1:9090',
          try_files => ['$uri =404'],
          www_root  => $path,
        }
      }
    }

    apache: {
      apache::vhost { $vhost:
        docroot         => $path,
        default_vhost   => true,
        port            => 80,
        serveradmin     => "vagrant@${vhost}",
        override        => 'all',
        custom_fragment => 'ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/$1',
      }
    }

    default: {
      fail("Webserver type ${profile::webserver::type} not supported by ${name}")
    }
  }
}
