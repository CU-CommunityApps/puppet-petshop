require 'spec_helper'

describe 'petshop', :type => 'class' do

  context 'with defaults for all parameters' do
    it { should contain_class('petshop') }
    it { should contain_class('petshop::base') }
  end
end
