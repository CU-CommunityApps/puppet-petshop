#
# Manifest to be run first thing after container launch.
#
class petshop::launch (
  # $petshop_user_id = hiera('petshop_user_id'),
  # $petshop_password = hiera('petshop_password'),
  # $container_memory_mb = hiera('container_memory_mb')
  ) {

    file { [
        '/tmp/launch'
        ] :
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 0775,
    }

    file { '/tmp/launch/kms-decrypt-files.sh' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0755,
      source => "puppet:///modules/petshop/kms-secrets/kms-decrypt-files.sh",
    } ->
    file { '/tmp/launch/service.conf.encrypted' :
      ensure  => present,
      owner   => www-data,
      group   => www-data,
      mode    => 0644,
      source => "puppet:///modules/petshop/kms-secrets/service.${environment}.conf.encrypted",
    } ->
    exec { 'decrypt' :
      command => "./kms-decrypt-files.sh service.conf.encrypted",
      cwd     => "/tmp/launch"
    }
  }