require 'spec_helper'

describe 'openresty::config' do
  let(:facts) do
    {
      :boxen_home => '/test/boxen'
    }
  end

  it do
    should include_class('boxen::config')
  end
end
