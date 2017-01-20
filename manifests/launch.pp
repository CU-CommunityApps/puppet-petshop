#
# Manifest to be run first thing after container launch.
#
class petshop::launch (
  # $petshop_user_id = hiera('petshop_user_id'),
  # $petshop_password = hiera('petshop_password'),
  # $container_memory_mb = hiera('container_memory_mb')
  ) {

    #######################################
    # Do manual decryption
    #######################################

    exec { 'manual_decrypt_secrets' :
      command => '/tmp/secrets/manual-kms/kms-decrypt-files.sh service.conf.encrypted',
      cwd     => '/tmp/secrets/manual-kms/',
    }

    #######################################
    # Do hiera-eyaml-kms decryption
    #######################################

    exec { 'eyaml_decrypt_secrets' :
      command => '/usr/local/bin/eyaml decrypt --trace -f service.conf.eyaml-encrypted > service.conf',
      cwd     => '/tmp/secrets/hiera-eyaml-kms/',
      logoutput => 'true',
    }

    # This just sets the owner, group, mode. Doesn't specify content.
    file { ['/tmp/secrets/manual-kms/service.conf',
            '/tmp/secrets/hiera-eyaml-kms/service.conf'] :
      ensure  => 'present',
      replace => 'no',
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0400',
    }


}