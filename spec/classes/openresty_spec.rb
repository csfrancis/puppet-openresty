require 'spec_helper'

describe 'openresty' do
  let(:facts) do
    {
      :boxen_home => '/test/boxen'
    }
  end

  it do
    should include_class('openresty::config')
    should include_class('homebrew')

    should contain_file('/Library/LaunchDaemons/dev.nginx.plist').with({
      :group  => 'wheel',
      :notify => 'Service[dev.nginx]',
      :owner  => 'root'
    })

    should contain_file('/test/boxen/config/nginx').with_ensure('directory')
    should contain_file('/test/boxen/data/nginx').with_ensure('directory')
    should contain_file('/test/boxen/log/nginx').with_ensure('directory')
    should contain_file('/test/boxen/config/nginx/sites').
      with_ensure('directory')

    should contain_file('/test/boxen/config/nginx/nginx.conf').
      with_notify('Service[dev.nginx]')

    should contain_file('/test/boxen/config/nginx/mime.types').with({
      :notify => 'Service[dev.nginx]',
      :source => 'puppet:///modules/openresty/config/nginx/mime.types'
    })

    should contain_file('/test/boxen/config/nginx/public').with({
      :ensure  => 'directory',
      :recurse => true,
      :source  => 'puppet:///modules/openresty/config/nginx/public'
    })

    should contain_homebrew__formula('openresty').
      with_before('Package[boxen/brews/openresty]')

    should contain_package('boxen/brews/openresty').with({
      :ensure => '1.4.2.1-boxen',
      :notify => 'Service[dev.nginx]'
    })

    should contain_file('/test/boxen/homebrew/etc/nginx').with({
      :ensure  => 'absent',
      :force   => true,
      :recurse => true,
      :require => 'Package[boxen/brews/nginx]'
    })

    should contain_service('dev.nginx').with({
      :ensure  => 'running',
      :require => 'Package[boxen/brews/openresty]',
    })
  end

end
