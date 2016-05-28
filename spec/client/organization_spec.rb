require 'client_helper'

describe Cyclid::Client::Job do
  context 'retrieving organization information' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'returns a list of organizations' do
      org_list = [{'name' => 'test'}]

      stub_request(:get, "http://localhost:9999/organizations")
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => org_list.to_json, :headers => {})

      orgs = []
      expect{ orgs = @client.org_list }.to_not raise_error
      expect( orgs ).to match_array(['test'])
    end

    it 'returns a valid organization' do
      stub_request(:get, "http://localhost:9999/organizations/test")
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      org = {}
      expect{ org = @client.org_get('test') }.to_not raise_error
      expect( org['test'] ).to eq('data')
    end
  end

  context 'retrieving organization member information' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'returns details of an organization member' do
      stub_request(:get, "http://localhost:9999/organizations/test/members/bob")
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      user = {}
      expect{ user = @client.org_user_get('test', 'bob') }.to_not raise_error
      expect( user['test'] ).to eq('data')
    end
  end

  context 'retrieving an organization plugin configuration' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'returns a plugin configuration for an organization' do
      stub_request(:get, "http://localhost:9999/organizations/test/configs/type/plugin")
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      config = {}
      expect{ config = @client.org_config_get('test', 'type', 'plugin') }.to_not raise_error 
      expect( config['test'] ).to eq('data')
    end
  end 
end
