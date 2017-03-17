#
# Manifest to be run first thing after container launch.
#
class petshop::launch (
  $petshop_user_id = hiera('petshop_user_id'),
  $petshop_password = hiera('petshop_password'),
  $container_memory_mb = hiera('container_memory_mb')
  ) {

    #######################################
    # Do manual decryption
    #######################################

    # Decrypt the file and save it as service.launch.conf
    exec { 'manual_decrypt_secrets' :
      command => '/tmp/secrets/manual-kms/kms-decrypt-files.sh service.conf.encrypted && mv service.conf service.launch.conf',
      cwd     => '/tmp/secrets/manual-kms/',
      logoutput => 'true'
    }

    # This just sets the owner, group, mode. Doesn't specify content.
    # No depency between the exec resource and this file resource is required.
    file { '/tmp/secrets/manual-kms/service.launch.conf' :
      ensure  => present,
      replace => no,
      owner   => www-data,
      group   => www-data,
      mode    => 0400,
    }

    #######################################
    # Do hiera-eyaml-kms decryption
    #######################################

    # Create a whole file from an encrypted hiera-data property (service_conf)
    file { '/tmp/secrets/hiera-eyaml-kms/service.launch.whole-file.conf' :
        ensure  => present,
        owner   => www-data,
        group   => www-data,
        mode    => 0400,
        content => hiera('service_conf'),
    }

    # Populate an example template, based on hiera-eyaml-secrets.
    # This forms an example of decrypting secrets
    # at launch time.
    file { '/tmp/secrets/hiera-eyaml-kms/service.launch.conf' :
        ensure  => present,
        owner   => www-data,
        group   => www-data,
        mode    => 0400,
        content => template('petshop/service.conf.erb'),
    }
}