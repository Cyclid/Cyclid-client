# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
require 'client_helper'

describe Cyclid::Client::User do
  context 'retrieving organization information' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
    end

    it 'returns a list of users' do
      user_list = [{ 'username' => 'bob' }]

      stub_request(:get, 'http://localhost:9999/users')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: user_list.to_json, headers: {})

      users = []
      expect{ users = @client.user_list }.to_not raise_error
      expect(users).to match_array(['bob'])
    end

    it 'returns a valid user' do
      stub_request(:get, 'http://localhost:9999/users/bob')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      user = {}
      expect{ user = @client.user_get('bob') }.to_not raise_error
      expect(user['test']).to eq('data')
    end
  end

  context 'creating users' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
    end

    it 'creates a new user without a password or secret specified' do
      stub_request(:post, 'http://localhost:9999/users')
        .with(body: '{"username":"bob","email":"bob@example.com"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = {}
      expect{ res = @client.user_add('bob', 'bob@example.com') }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'creates a new user with a secret specified' do
      stub_request(:post, 'http://localhost:9999/users')
        .with(body: '{"username":"bob","email":"bob@example.com","secret":"sekrit"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = {}
      expect{ res = @client.user_add('bob', 'bob@example.com', nil, nil, 'sekrit') }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'creates a new user with a password specified' do
      stub_request(:post, 'http://localhost:9999/users')
        .with(body: /{"username":"bob","email":"bob@example.com","password":".*"}/,
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = {}
      expect{ res = @client.user_add('bob', 'bob@example.com', nil, 'm1lkb0ne') }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'creates a new user with a previously encrypted password specified' do
      stub_request(:post, 'http://localhost:9999/users')
        .with(body: /{"username":"bob","email":"bob@example.com","password":"\$2a\$10\$42uBIU4TTVTWAYs2rUN\.dO9HumdFHxsLa3qqQ2U0SvNZFMuljNhQO"}/,
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = {}
      expect{ res = @client.user_add('bob', 'bob@example.com', nil, '$2a$10$42uBIU4TTVTWAYs2rUN.dO9HumdFHxsLa3qqQ2U0SvNZFMuljNhQO') }.to_not raise_error
      expect(res['test']).to eq('data')
    end
  end

  context 'modifying users' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
    end

    it 'changes the users email address' do
      stub_request(:put, 'http://localhost:9999/users/bob')
        .with(body: '{"email":"bob@example.com"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      new_user = { email: 'bob@example.com' }

      res = {}
      expect{ res = @client.user_modify('bob', new_user) }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'changes the users secret' do
      stub_request(:put, 'http://localhost:9999/users/bob')
        .with(body: '{"secret":"sekrit"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      new_user = { secret: 'sekrit' }

      res = {}
      expect{ res = @client.user_modify('bob', new_user) }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'changes the users password' do
      stub_request(:put, 'http://localhost:9999/users/bob')
        .with(body: /{"password":".*"}/,
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      new_user = { password: 'm1lkb0ne' }

      res = {}
      expect{ res = @client.user_modify('bob', new_user) }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'changes the users password with a previously encrypted password' do
      stub_request(:put, 'http://localhost:9999/users/bob')
        .with(body: /{"password":"\$2a\$10\$42uBIU4TTVTWAYs2rUN\.dO9HumdFHxsLa3qqQ2U0SvNZFMuljNhQO"}/,
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      new_user = { password: '$2a$10$42uBIU4TTVTWAYs2rUN.dO9HumdFHxsLa3qqQ2U0SvNZFMuljNhQO' }

      res = {}
      expect{ res = @client.user_modify('bob', new_user) }.to_not raise_error
      expect(res['test']).to eq('data')
    end
  end

  context 'deleting users' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
    end

    it 'deletes a user' do
      stub_request(:delete, 'http://localhost:9999/users/bob')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = {}
      expect{ res = @client.user_delete('bob') }.to_not raise_error
      expect(res['test']).to eq('data')
    end
  end
end
