require 'spec_helper'
describe 'petshop::launch', :type => 'class' do

  context 'with defaults for all parameters' do
    # FIXME Why aren't these working?
    #it { is_expected.to contain_file('/tmp/secrets/manual-kms/service.conf.encrypted') }
    #it { is_expected.to contain_file('/tmp/secrets/manual-kms/kms-decrypt-files.sh') }
    #it { is_expected.to contain_file('/tmp/secrets/hiera-eyaml-kms/service.conf.eyaml-encrypted') }
    #it { is_expected.to contain_file('/usr/share/nginx/html/index.html') }
  end

end
