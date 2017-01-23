#
# Manifest to be run first thing after container launch.
#
class petshop::launch (
  # $petshop_user_id = hiera('petshop_user_id'),
  # $petshop_password = hiera('petshop_password'),
  # $container_memory_mb = hiera('container_memory_mb')
  # service_conf = hiera('service_conf')
  ) {

    #######################################
    # Do manual decryption
    #######################################

    exec { 'manual_decrypt_secrets' :
      command => '/tmp/secrets/manual-kms/kms-decrypt-files.sh service.conf.encrypted',
      cwd     => '/tmp/secrets/manual-kms/',
    }

    # This just sets the owner, group, mode. Doesn't specify content.
    file { '/tmp/secrets/manual-kms/service.conf' :
      ensure  => present,
      replace => no,
      owner   => www-data,
      group   => www-data,
      mode    => 0400,
    }

    #######################################
    # Do hiera-eyaml-kms decryption
    #######################################

    file { '/tmp/secrets/hiera-eyaml-kms/service.conf' :
        ensure  => present,
        owner   => www-data,
        group   => www-data,
        mode    => 0400,
        content => hiera('service_conf'),
    }

    # Populate am example template, based on hiera-eyaml-secrets
    file { '/usr/share/nginx/html/index.html' :
        ensure  => present,
        owner   => www-data,
        group   => www-data,
        mode    => 0644,
        content => template('petshop/index.html.erb'),
      }

}