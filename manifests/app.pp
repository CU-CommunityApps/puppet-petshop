class petshop::app (
  $petshop_user_id = hiera('petshop_user_id'),
  $petshop_password = hiera('petshop_password'),
  $container_memory_mb = hiera('container_memory_mb')
  ) {

    ###########################################################
    # Setting up for Elastic Beanstalk deployment package build
    ###########################################################
    file { [
      '/tmp/build',
      '/tmp/build/.ebextensions'
      ] :
      ensure  => directory,
      owner   => www-data,
      group   => www-data,
      mode    => 0775,
    }

    # These resources are applied in order, as told by "->"
    file { '/tmp/build/.ebextensions/utils.config' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      content  => template('petshop/eb/utils.config.erb'),
    } ->
    file { '/tmp/build/Dockerrun.aws.json' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      content  => template('petshop/eb/Dockerrun.aws.v2.json.erb'),
    } ->
    exec { 'eb-package' :
      command => "/usr/bin/zip ../${app_name}-${environment}-${build_number}.zip -r * .ebextensions",
      cwd     => "/tmp/build"
    }
    ###########################################################
    # End setup for Elastic Beanstalk deployment package build
    ###########################################################

    ############################################
    # Setting up for manual decryption at launch
    ############################################
    file { [
        '/tmp/secrets/',
        '/tmp/secrets/manual-kms'] :
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 0775,
    }

    file { '/tmp/secrets/manual-kms/service.conf.encrypted' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      source => "puppet:///modules/petshop/kms-secrets/service.${environment}.conf.encrypted",
    }

    file { '/tmp/secrets/manual-kms/kms-decrypt-files.sh' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0755,
      source => "puppet:///modules/petshop/kms-secrets/kms-decrypt-files.sh",
    }
    ############################################
    # End manual decryption SETUP
    ############################################

    ############################################
    # Setting up for manual decryption at launch
    ############################################

    file { ['/etc/eyaml'] :
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 0755,
    }

    file { '/etc/eyaml/config.yaml' :
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0644,
      source => "puppet:///modules/petshop/kms-secrets/eyaml.config",
    }

    file { [
        '/tmp/secrets/hiera-eyaml-kms'] :
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 0775,
    }

    file { '/tmp/secrets/hiera-eyaml-kms/service.conf.eyaml-encrypted' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      source => "puppet:///modules/petshop/kms-secrets/service.${environment}.conf.eyaml-encrypted",
    }

    ############################################
    # End setup for manual decryption at launch
    ############################################

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