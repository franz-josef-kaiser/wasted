class component::zend_framework1 (
  $path = hiera('path', '/var/www/app_name'),
  $vhost = hiera('vhost', 'app-name.dev'),
  $env = hiera('env', 'dev'),
) {

  case $profile::webserver::type {
    nginx: {
      nginx::resource::vhost { $vhost:
        www_root            => "${path}/public",
        fastcgi             => '127.0.0.1:9000',
        location_cfg_append => {
          fastcgi_index => 'index.php',
          fastcgi_param => [
            'SCRIPT_FILENAME $document_root/index.php',
            "APPLICATION_ENV ${env}"
          ]
        },
      }

      nginx::resource::location{ "${vhost}_static":
        location  => '~ ^/(style|images|scripts)/',
        vhost     => $vhost,
        www_root  => "${path}/public",
        try_files => ['$uri', '=404']
      }

      if defined(Class['::hhvm']) {
        nginx::resource::vhost { "hhvm.${vhost}":
          www_root            => "${path}/public",
          fastcgi             => '127.0.0.1:9090',
          location_cfg_append => {
            fastcgi_index => 'index.php',
            fastcgi_param => [
              'SCRIPT_FILENAME $document_root/index.php',
              "APPLICATION_ENV ${env}"
            ]
          },
        }

        nginx::resource::location{ "hhvm.${vhost}_static":
          location  => '~ ^/(style|images|scripts)/',
          vhost     => "hhvm.${vhost}",
          www_root  => "${path}/public",
          try_files => ['$uri', '=404']
        }
      }
    }

    default: {
      fail("Webserver type ${profile::webserver::type} not supported by ${name}")
    }
  }
}
