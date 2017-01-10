require 'spec_helper'
describe 'petshop::app', :type => 'class' do

  context 'with defaults for all parameters' do
    it { is_expected.to contain_file('/tmp/sample/sample.conf') }
    it { is_expected.to contain_file('/tmp/example/example.conf') }
    it { is_expected.to contain_file('/etc/nginx/sites-available/default') }
    it { is_expected.to contain_file('/usr/share/nginx/html/index.html') }
  end

end
