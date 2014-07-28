class component::standalone_app (
  $path   = hiera('path', '/var/www/app_name'),
  $vhost  = hiera('vhost', 'app-name.dev'),
  $port   = 5000,
  $prefix = 'api'
) {

  case $profile::webserver::type {
    nginx: {
      nginx::resource::vhost { $vhost:
        www_root    => $path,
        index_files => ['index.html'],
        try_files   => ['$uri', '$uri/', '/index.html', '=404'],
      }

      nginx::resource::upstream { 'standalone_app':
        members => [
          "localhost:${port}",
        ],
      }

      nginx::resource::location { "/${prefix}":
        vhost => $vhost,
        proxy => 'http://standalone_app',
      }
    }

    default: {
      fail("Webserver type ${profile::webserver::type} not supported by ${name}")
    }
  }
}
