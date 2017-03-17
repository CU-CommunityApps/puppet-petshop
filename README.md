# NOTES

See primary documentation in [puppet-docker](https://github.com/CU-CommunityApps/docker-petshop).

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



