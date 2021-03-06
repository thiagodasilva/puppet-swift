require 'spec_helper'
# LP1492636 - Cohabitation of compile matcher and webmock
WebMock.disable_net_connect!(:allow => "169.254.169.254")

describe 'swift::ringserver' do

  context 'when storage.pp was already included' do

    let :pre_condition do
      "class { 'swift::storage': storage_local_net_ip  => '127.0.0.1' }
       class {'swift' : swift_hash_path_suffix => 'eee' }
       include swift::ringbuilder"
    end

    let :facts do
      OSDefaults.get_facts({
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
      })
    end

    let :params do
      {
        :local_net_ip    => '127.0.0.1',
        :max_connections => 5
      }
    end

    it 'does not create the rsync::server class' do
      is_expected.to compile
    end

    it 'contain the swift_server rsync block' do
      is_expected.to contain_rsync__server__module('swift_server').with({
        'path'            => '/etc/swift',
        'lock_file'       => '/var/lock/swift_server.lock',
        'uid'             => 'swift',
        'gid'             => 'swift',
        'max_connections' => '5',
        'read_only'       => 'true'
      })
    end

  end

  context 'when storage.pp was not already included' do

    let :pre_condition do
      "class {'swift' : swift_hash_path_suffix => 'eee' }
       include swift::ringbuilder"
    end

    let :facts do
      OSDefaults.get_facts({
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
      })
    end


    let :params do
      {
        :local_net_ip    => '127.0.0.1',
        :max_connections => 5
      }
    end

    it 'does create the rsync::server class' do
      is_expected.to contain_class('rsync::server').with({
        'use_xinetd' => 'true',
        'address'    => '127.0.0.1',
        'use_chroot' => 'no'
      })
    end

    it 'contain the swift_server rsync block' do
      is_expected.to contain_rsync__server__module('swift_server').with({
        'path'            => '/etc/swift',
        'lock_file'       => '/var/lock/swift_server.lock',
        'uid'             => 'swift',
        'gid'             => 'swift',
        'max_connections' => '5',
        'read_only'       => 'true'
      })
    end

  end

end
