require 'spec_helper'
describe 'petshop::launch', :type => 'class' do

  context 'with defaults for all parameters' do
    it { is_expected.to contain_file('/tmp/launch/service.conf.encrypted') }
    # it { is_expected.to contain_file('/tmp/launch/service.conf') }
    it { is_expected.to contain_file('/tmp/launch/kms-decrypt-files.sh') }
  end

end
