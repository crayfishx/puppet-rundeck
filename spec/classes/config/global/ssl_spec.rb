require 'spec_helper'

describe 'rundeck::config::global::ssl' do
  context 'supported operating systems' do
    SUPPORTED_FAMILIES.each do |osfamily|
      describe "rundeck::config::global::ssl class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
            :osfamily => osfamily,
        }}

        ssl_details = {
          'keystore' => '/etc/rundeck/ssl/keystore',
          'keystore.password' => 'adminadmin',
          'key.password' => 'adminadmin',
          'truststore' => '/etc/rundeck/ssl/truststore',
          'truststore.password' => 'adminadmin'
        }

        it { should contain_file('/etc/rundeck/ssl').with({ 'ensure' => 'directory'}) }
        it { should contain_file('/etc/rundeck/ssl/ssl.properties') }

        ssl_details.each do |key,value|
          it { should contain_ini_setting(key).with(
            'path'    => '/etc/rundeck/ssl/ssl.properties',
            'setting' => key,
            'value'   => value
          ) }
        end

      end
    end
  end
end