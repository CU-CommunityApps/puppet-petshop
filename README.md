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

NOTE: In order for 'eyaml' command two work correctly with KMS at via puppet at launch inside a container running on a local workstation, you must set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables in the shell that is running puppet or eyaml. E.g. before calling puppet in lauch.sh. For some reason, the hiera-eyaml-kms gem doesn't automatically use the credentials files at ~/.aws, even when they are mapped into a local container using -v ~/.aws:/root/.aws. Arg!

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
