# NOTES

## Setup yourself up for encrypting secrets.

* Install eyaml on your local machine:

  ```
  $ gem install hiera-eyaml
  ```

* Create keys
  ```
  $ eyaml createkeys
  ```

## Use hiera-eyaml-kms

```
eyaml encrypt -f service.dev.conf | grep string | cut -c 9- | tr -d '\n' > service.dev.conf.eyaml-encrypted
eyaml decrypt -f service.dev.conf.eyaml-encrypted > service.dev.conf.eyaml-decrypted
diff --report-identical-files service.dev.conf service.dev.conf.eyaml-decrypted
````

## Use hiera directly from within container

```
hiera -c /modules/petshop/hiera.yaml petshop_password environment=local
```


## Setup the project to pull the puppet-petshop project from Github:

* create deploy key for puppet-petshop and/or docker-petshop

  ```
  $ ssh-keygen -t rsa -b 4096 -f ./keys/id_rsa
  ```

* Add that key as a deploy key for petshop-puppet git repo (in Github). I.e. `id_rsa.pub`.


## Testing Your Puppet Configuration

$ docker build -t puppet-test .
$ docker run -i puppet-test rake spec
$ docker run -i puppet-test rake validate
