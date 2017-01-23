# NOTES

## To Do

- Update rake tasks or run-tests.sh so that launch_spec.rb can run properly.

## Setup the docker-petshop project to pull the puppet-petshop project from Github

* Create a deploy key for puppet-petshop

  ```
  $ cd /to/your/docker-petshop/project/directory
  $ ssh-keygen -t rsa -b 4096 -f ./keys/id_rsa
  ```

* Add that key as a deploy key for petshop-puppet git repo (in Github). I.e. `id_rsa.pub`. See instructions at https://developer.github.com/guides/managing-deploy-keys/#deploy-keys.


## Testing Your Puppet Configuration

The [run-tests.sh](run-tests.sh) script runs spec tests and validations for the puppet-petshop repo.

  ```
  $ ./run-tests.sh
  Sending build context to Docker daemon 561.2 kB
  Step 1 : FROM ruby:2.1-onbuild
  # Executing 4 build triggers...
  Step 1 : COPY Gemfile /usr/src/app/
   ---> Using cache
  Step 1 : COPY Gemfile.lock /usr/src/app/
   ---> Using cache
  Step 1 : RUN bundle install
   ---> Using cache
  Step 1 : COPY . /usr/src/app
   ---> 110e2e16d51d
  Removing intermediate container e1abde7d4472
  Successfully built 110e2e16d51d
  /usr/local/bin/ruby -I/usr/local/bundle/gems/rspec-core-3.5.2/lib:/usr/local/bundle/gems/rspec-support-3.5.0/lib /usr/local/bundle/gems/rspec-core-3.5.2/exe/rspec --pattern spec/\{classes,defines,unit,functions,hosts,integration,types\}/\*\*/\*_spec.rb --color
  ........

  Finished in 0.34283 seconds (files took 0.43543 seconds to load)
  8 examples, 0 failures

  ---> syntax:manifests
  ---> syntax:templates
  ---> syntax:hiera:yaml
  puppet parser validate --noop manifests/base.pp
  puppet parser validate --noop manifests/init.pp
  puppet parser validate --noop manifests/launch.pp
  puppet parser validate --noop manifests/app.pp
  ruby -c spec/spec_helper.rb
  Syntax OK
  ruby -c spec/classes/init_spec.rb
  Syntax OK
  ruby -c spec/classes/base_spec.rb
  Syntax OK
  ruby -c spec/classes/app_spec.rb
  Syntax OK
  ruby -c spec/classes/launch_spec.rb
  Syntax OK
  erb -P -x -T '-' templates/index.html.erb | ruby -c
  Syntax OK
  erb -P -x -T '-' templates/eb/utils.config.erb | ruby -c
  Syntax OK
  erb -P -x -T '-' templates/eb/Dockerrun.aws.v2.json.erb | ruby -c
  Syntax OK
  ```

## Setup a KMS key to used

See the kms-key.json in docker-petshop/cloud-formation for a CloudFormation template to create a KMS specifically for this application to manage secrets using KMS.

## Set yourself up for encrypting secrets using hiera-eyaml-kms at the command line

* Install hiera-eyaml and supporting gems on your local machine:

  ```
  $ gem install hiera-eyaml
  $ gem install aws-sdk
  $ gem install hiera-eyaml-kms
  ```

* Setup an the eyaml config file. Copy and paste the lines below into  `~/.eyaml/config.yaml`. Replace the KMS key id with the one you created above.

  ```
  encrypt_method: 'KMS'
  kms_key_id: '4c044060-5160-4738-9c7b-009e7fc2c104'
  kms_aws_region: 'us-east-1'
  ```

  If you wish, you can skip setup of the `~/.eyaml/config.yaml` file and use these eyaml arguments each time you execute it:

  ```
  --kms-key-id=<your_KMS_key_id>
  --kms-aws-region=<your_AWS_region>
  --encrypt-method=KMS
  ```

* Confirm that hiera-eyaml works and knows about the KMS plugin.

  ```
  $ eyaml version
  $ eyaml version
  [hiera-eyaml-core] Loaded config from /Users/pea1/.eyaml/config.yaml
  [hiera-eyaml-core] hiera-eyaml (core): 2.1.0
  [hiera-eyaml-core] hiera-eyaml-kms (gem): 0.1
  ```

* Test string encryption.

  ```
  $ eyaml encrypt -s "Hello world"
  [hiera-eyaml-core] Loaded config from /Users/pea1/.eyaml/config.yaml
  string: ENC[KMS,AQECAHhpScaf3XF9NVK+U6wXpeDoju8w8Ccbz3O4+LbMCXi+UQAAAGkwZwYJKoZIhvcNAQcGoFowWAIBADBTBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDLz6zMdtnIsNxNzw9gIBEIAmhv1St9i1uybeGDyq6bWgQvt8C3uDK5W8bYdwrBdPDgYjJvKIrPs=]

  OR

  block: >
      ENC[KMS,AQECAHhpScaf3XF9NVK+U6wXpeDoju8w8Ccbz3O4+LbMCXi+UQAAAGkwZwYJ
      KoZIhvcNAQcGoFowWAIBADBTBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEE
      DLz6zMdtnIsNxNzw9gIBEIAmhv1St9i1uybeGDyq6bWgQvt8C3uDK5W8bYdw
      rBdPDgYjJvKIrPs=]
  ```

* Test string decryption using the encrypted data from above:

  ```
  $ eyaml decrypt -s ENC[KMS,AQECAHhpScaf3XF9NVK+U6wXpeDoju8w8Ccbz3O4+LbMCXi+UQAAAGkwZwYJKoZIhvcNAQcGoFowWAIBADBTBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDLz6zMdtnIsNxNzw9gIBEIAmhv1St9i1uybeGDyq6bWgQvt8C3uDK5W8bYdwrBdPDgYjJvKIrPs=]
  [hiera-eyaml-core] Loaded config from /Users/pea1/.eyaml/config.yaml
  Hello world
  ```

* Troubleshooting. Use `--trace` option with eyaml to get more details about what it's doing.

  ```
  $ eyaml encrypt --trace -s "Hello world"
  [hiera-eyaml-core] Loaded config from /Users/pea1/.eyaml/config.yaml
  [hiera-eyaml-core] Dump of eyaml tool options dict:
  [hiera-eyaml-core] --------------------------------
  [hiera-eyaml-core]           (Symbol) encrypt_method     =           (String) KMS               
  [hiera-eyaml-core]           (Symbol) version            =       (FalseClass) false             
  [hiera-eyaml-core]           (Symbol) verbose            =       (FalseClass) false             
  [hiera-eyaml-core]           (Symbol) trace              =        (TrueClass) true              
  [hiera-eyaml-core]           (Symbol) quiet              =       (FalseClass) false             
  [hiera-eyaml-core]           (Symbol) help               =       (FalseClass) false             
  [hiera-eyaml-core]           (Symbol) password           =       (FalseClass) false             
  [hiera-eyaml-core]           (Symbol) string             =           (String) Hello world       
  [hiera-eyaml-core]           (Symbol) file               =         (NilClass)                   
  [hiera-eyaml-core]           (Symbol) stdin              =       (FalseClass) false             
  [hiera-eyaml-core]           (Symbol) eyaml              =         (NilClass)                   
  [hiera-eyaml-core]           (Symbol) output             =           (String) examples          
  [hiera-eyaml-core]           (Symbol) label              =         (NilClass)                   
  [hiera-eyaml-core]           (Symbol) pkcs7_private_key  =           (String) ./keys/private_key.pkcs7.pem
  [hiera-eyaml-core]           (Symbol) pkcs7_public_key   =           (String) ./keys/public_key.pkcs7.pem
  [hiera-eyaml-core]           (Symbol) pkcs7_subject      =           (String) /                 
  [hiera-eyaml-core]           (Symbol) kms_key_id         =           (String) 4c044060-5160-4738-9c7b-009e7fc2c104
  [hiera-eyaml-core]           (Symbol) kms_aws_region     =           (String) us-east-1         
  [hiera-eyaml-core]           (Symbol) trace_given        =        (TrueClass) true              
  [hiera-eyaml-core]           (Symbol) string_given       =        (TrueClass) true              
  [hiera-eyaml-core]           (Symbol) executor           =            (Class) Hiera::Backend::Eyaml::Subcommands::Encrypt
  [hiera-eyaml-core]           (Symbol) source             =           (Symbol) string            
  [hiera-eyaml-core]           (Symbol) input_data         =           (String) Hello world       
  [hiera-eyaml-core] --------------------------------
  string: ENC[KMS,AQECAHhpScaf3XF9NVK+U6wXpeDoju8w8Ccbz3O4+LbMCXi+UQAAAGkwZwYJKoZIhvcNAQcGoFowWAIBADBTBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDGHlknGK3qO7dJcdXAIBEIAm7GxN3b8dxll4mBUMdyC6W9ln69Zp11rgs6GupHty6uB/kgKpAd0=]

  OR

  block: >
      ENC[KMS,AQECAHhpScaf3XF9NVK+U6wXpeDoju8w8Ccbz3O4+LbMCXi+UQAAAGkwZwYJ
      KoZIhvcNAQcGoFowWAIBADBTBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEE
      DGHlknGK3qO7dJcdXAIBEIAm7GxN3b8dxll4mBUMdyC6W9ln69Zp11rgs6Gu
      pHty6uB/kgKpAd0=]
  ```

* Note that the [hiera.yaml](hiera.yaml) configuration file packaged with this project drives the eyaml configuration when Puppet is run within the context of the project Dockerfiles and testing scripts.

* Some text editors have plugins that will allow you to do eyaml encryption and decryption directly, without using the command line. E.g. https://atom.io/packages/hiera-eyaml

* See https://github.com/TomPoulton/hiera-eyaml for further details. The KMS plugin for hiera-eyaml is https://github.com/adenot/hiera-eyaml-kms.

### Misc hiera-eyaml-kms Notes

* Note that the [hiera.yaml](hiera.yaml) configuration file packaged with this project drives the eyaml configuration when Puppet is run within the context of the project Dockerfiles and testing scripts.

* Some text editors have plugins that will allow you to do eyaml encryption and decryption directly, without using the command line. E.g. https://atom.io/packages/hiera-eyaml

* See https://github.com/TomPoulton/hiera-eyaml for further details. The KMS plugin for hiera-eyaml is https://github.com/adenot/hiera-eyaml-kms.

#### Use hiera-eyaml-kms from within a container running on a local workstation

In order for the `eyaml` command two work correctly with KMS via a Puppet manifest at launch inside a container running on a local workstation, you must set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables in the shell that is running Puppet. For some reason, the hiera-eyaml-kms gem doesn't automatically use the credentials files at ~/.aws, even when they are mapped into a local container using -v ~/.aws:/root/.aws and the root user is running the Puppet manifest.

#### Use eyaml to encrypt whole files.

```
eyaml encrypt -f service.dev.conf | grep string | cut -c 9- | tr -d '\n' > service.dev.conf.eyaml-encrypted
eyaml decrypt -f service.dev.conf.eyaml-encrypted > service.dev.conf.eyaml-decrypted
diff --report-identical-files service.dev.conf service.dev.conf.eyaml-decrypted
```

### Use hiera directly from within container

Puppet uses the hiera tool to lookup atttribute values from hiera-eyaml properties files. You can also use this tool directly in a shell script in a container if the Puppet tooling is present.

```
$ hiera -c /modules/petshop/hiera.yaml petshop_password environment=local
'dummy-local-password'
$
```
