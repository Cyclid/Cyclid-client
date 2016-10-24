# frozen_string_literal: true
# rubocop:disable Metrics/LineLength
require 'client_helper'

describe Cyclid::Client::Tilapia do
  context 'initialising a client' do
    it 'creates a new client with a valid configuration path' do
      client = nil
      expect{ client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG']) }.to_not raise_error
      expect(client.config).to be_an_instance_of(Cyclid::Client::Config)
      expect(client.logger).to be_an_instance_of(Logger)
      expect(client.logger.level).to eq(Logger::FATAL)
    end

    it 'creates a new client with a non-default log level' do
      client = nil
      expect{ client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'], log_level: Logger::DEBUG) }.to_not raise_error
      expect(client.logger.level).to eq(Logger::DEBUG)
    end

    it 'aborts if the configuration path is invalid' do
      expect{ Cyclid::Client::Tilapia.new(path: '/does/not/exist') }.to raise_error
    end
  end

  context 'parsing server responses' do
    before :each do
      # Expose the private methods
      Cyclid::Client::Tilapia.send(:public, *Cyclid::Client::Tilapia.private_instance_methods)

      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      @uri = @client.server_uri('/example/test')
    end

    it 'parses a valid 200 response' do
      stub_request(:get, 'http://localhost:9999/example/test')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = nil
      expect{ res = @client.api_get(@uri) }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'handles a non-200 server response' do
      stub_request(:get, 'http://localhost:9999/example/test')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 500, body: '{"test": "data"}', headers: {})

      expect{ @client.api_get(@uri) }.to raise_error
    end

    it 'handles a 200 server response with an invalid body' do
      stub_request(:get, 'http://localhost:9999/example/test')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: 'this is invalid', headers: {})

      expect{ @client.api_get(@uri) }.to raise_error
    end
  end
end
