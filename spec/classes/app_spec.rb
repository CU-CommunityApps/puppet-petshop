require 'spec_helper'
describe 'petshop::app', :type => 'class' do

  context 'with defaults for all parameters' do
    it { is_expected.to contain_file('/tmp/secrets/manual-kms/service.conf.encrypted') }
    it { is_expected.to contain_file('/tmp/secrets/manual-kms/kms-decrypt-files.sh') }
    it { is_expected.to contain_file('/tmp/secrets/manual-kms/service.build.conf') }
    it { is_expected.to contain_file('/tmp/secrets/hiera-eyaml-kms/service.build.conf') }
    it { is_expected.to contain_file('/tmp/sample/sample.conf') }
    it { is_expected.to contain_file('/etc/nginx/sites-available/default') }
  end
end
