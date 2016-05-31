require 'client_helper'

describe Cyclid::Client::Organization do
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

  context 'creating organizations' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'creates a new organization' do
      stub_request(:post, "http://localhost:9999/organizations")
        .with(:body => '{"name":"test","owner_email":"test@example.com"}',
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      org = {}
      expect{ org = @client.org_add('test', 'test@example.com') }.to_not raise_error
      expect( org['test'] ).to eq('data')
    end
  end

  context 'modifying an organization' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'changes the owner_email' do
      stub_request(:put, "http://localhost:9999/organizations/test")
        .with(:body => '{"owner_email":"test@example.com"}',
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      args = {owner_email: 'test@example.com'}

      res = {}
      expect{ res = @client.org_modify('test', args) }.to_not raise_error
      expect( res['test'] ).to eq('data')
    end

    it 'changes the member list' do
      stub_request(:put, "http://localhost:9999/organizations/test")
        .with(:body => '{"users":["test@example.com"]}',
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      args = {members: ['test@example.com']}

      res = {}
      expect{ res = @client.org_modify('test', args) }.to_not raise_error
      expect( res['test'] ).to eq('data')
    end

    it 'updates the organization if no owner_email or users list is provided' do
      stub_request(:put, "http://localhost:9999/organizations/test")
        .with(:body => '{}',
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      res = {}
      expect{ res = @client.org_modify('test', {}) }.to_not raise_error
      expect( res['test'] ).to eq('data')
    end

    it 'ignores unknown arguments' do
      stub_request(:put, "http://localhost:9999/organizations/test")
        .with(:body => '{}',
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      args = {unknown: 'argument'}

      res = {}
      expect{ res = @client.org_modify('test', args) }.to_not raise_error
      expect( res['test'] ).to eq('data')
    end
  end

  context 'deleting an organization' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'deletes an organization' do
      stub_request(:delete, "http://localhost:9999/organizations/test")
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      res = nil
      expect{ res = @client.org_delete('test') }.to_not raise_error
      expect( res['test'] ).to eq('data')
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

  context 'changing a users permissions' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'modifies a users permissions' do
      stub_request(:put, "http://localhost:9999/organizations/test/members/bob")
        .with(:body => "{\"permissions\":{\"permissions\":\"test\"}}",
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      perms = {'permissions' => 'test'}

      res = nil
      expect{ res = @client.org_user_permissions('test', 'bob', perms) }.to_not raise_error
      expect( res['test'] ).to eq('data')
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

  context 'updating an organization plugin configuration' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'updates a configuration' do
      stub_request(:put, "http://localhost:9999/organizations/test/configs/type/plugin")
        .with(:body => "{\":test\":\"config\"}",
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => '{"test": "data"}', :headers => {})

      new_config = {test: 'config'}

      config = {}
      expect{ config = @client.org_config_set('test', 'type', 'plugin', new_config) }.to_not raise_error 
      expect( config['test'] ).to eq('data')
    end
  end
end
