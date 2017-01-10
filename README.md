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
