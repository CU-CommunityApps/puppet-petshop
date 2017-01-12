class petshop::app (
  $petshop_user_id = hiera('petshop_user_id'),
  $petshop_password = hiera('petshop_password'),
  $container_memory_mb = hiera('container_memory_mb')
  ) {

    file { [
      '/tmp/build',
      '/tmp/build/.ebextensions'
      ] :
      ensure  => directory,
      owner   => www-data,
      group   => www-data,
      mode    => 0775,
    }

    file { '/tmp/build/.ebextensions/utils.config' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      content  => template('petshop/eb/utils.config.erb'),
    }

    file { '/tmp/build/Dockerrun.aws.json' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      content  => template('petshop/eb/Dockerrun.aws.v2.json.erb'),
    }

    exec { 'eb-package' :
      command => "zip -r /tmp/build-${environment}.v${build_number}.zip /tmp/build"
    }

    file { [
        '/tmp/sample',
        '/tmp/example'] :
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 0775,
    }

    file { '/tmp/sample/sample.conf' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      source => "puppet:///modules/petshop/sample.${environment}.conf",
    }

    file { '/tmp/example/example.conf' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      source  => 'puppet:///modules/petshop/example.conf',
    }

    file { '/etc/nginx/sites-available/default' :
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0644,
      source  => 'puppet:///modules/petshop/nginx.default.conf',
    }

    file { '/usr/share/nginx/html/index.html' :
        ensure  => present,
        owner   => www-data,
        group   => www-data,
        mode    => 0644,
        content => template('petshop/index.html.erb'),
      }

  }