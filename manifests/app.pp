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
    # Manual decryption
    ############################################

    # Setup target directories for manual descryption
    file { [
        '/tmp/secrets/',
        '/tmp/secrets/manual-kms'] :
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 0775,
    }

    # Get the decryption script into the image
    file { '/tmp/secrets/manual-kms/kms-decrypt-files.sh' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0755,
      source => "puppet:///modules/petshop/kms-secrets/kms-decrypt-files.sh",
    } ->
    # Get the encrypted file in the image
    file { '/tmp/secrets/manual-kms/service.conf.encrypted' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      source => "puppet:///modules/petshop/kms-secrets/service.${environment}.conf.encrypted",
    } ->
    # An example of Docker build-time decryption.
    # Decrypts the file at build time and save in service.build.conf
    # The "->" ensures proper ordering for the file and exec resources.
    exec { 'manual_decrypt_secrets' :
      command => '/tmp/secrets/manual-kms/kms-decrypt-files.sh service.conf.encrypted && mv service.conf service.build.conf',
      cwd     => '/tmp/secrets/manual-kms/',
      logoutput => 'true',
    } ->
    # This just sets the owner, group, mode. Doesn't specify content.
    file { '/tmp/secrets/manual-kms/service.build.conf' :
      ensure  => present,
      replace => no,
      owner   => www-data,
      group   => www-data,
      mode    => 0400,
    }
    ############################################
    # End manual decryption
    ############################################

    ############################################
    # hiera-eyaml-based decryption
    ############################################

    # Setup target directories
    file { [
        '/tmp/secrets/hiera-eyaml-kms'] :
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 0775,
    }

    # Populate an example template, based on hiera-eyaml-secrets.
    # This forms an example of decrypted secrets
    # being stored in the Docker image.
    file { '/tmp/secrets/hiera-eyaml-kms/service.build.conf' :
        ensure  => present,
        owner   => www-data,
        group   => www-data,
        mode    => 0400,
        content => template('petshop/service.conf.erb'),
    }

    ############################################
    # Other sample Puppet directives, not related to secrets
    ############################################

    file { '/tmp/sample' :
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

    file { '/etc/nginx/sites-available/default' :
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0644,
      source  => 'puppet:///modules/petshop/nginx.default.conf',
    }

  }