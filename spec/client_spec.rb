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

  context 'signing requests' do
    # Expose the private methods
    before :each do
      Cyclid::Client::Tilapia.send(:public, *Cyclid::Client::Tilapia.private_instance_methods)
    end

    it 'creates a valid URI' do
      client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      expect(client.server_uri('/example/test')).to eq(URI('http://localhost:9999/example/test'))
    end

    it 'signs a GET request with HMAC' do
      client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      uri = client.server_uri('/example/test')
      request = Net::HTTP::Get.new(uri)

      api_request = nil
      expect{ api_request = client.sign_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'signs a POST request with HMAC' do
      client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      uri = client.server_uri('/example/test')
      request = Net::HTTP::Post.new(uri)

      api_request = nil
      expect{ api_request = client.sign_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'signs a PUT request with HMAC' do
      client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      uri = client.server_uri('/example/test')
      request = Net::HTTP::Put.new(uri)

      api_request = nil
      expect{ api_request = client.sign_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'signs a DELETE request with HMAC' do
      client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      uri = client.server_uri('/example/test')
      request = Net::HTTP::Delete.new(uri)

      api_request = nil
      expect{ api_request = client.sign_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'rejects non-GET/PUT/POST/DELETE requests' do
      client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      uri = client.server_uri('/example/test')
      request = Net::HTTP::Patch.new(uri)

      expect{ client.sign_request(request, uri) }.to raise_error
    end
  end

  context 'performing signed requests' do
    before :each do
      # Expose the private methods
      Cyclid::Client::Tilapia.send(:public, *Cyclid::Client::Tilapia.private_instance_methods)

      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
      @uri = @client.server_uri('/example/test')
    end

    it 'sends a signed GET' do
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

    it 'sends a signed POST with a JSON body' do
      stub_request(:post, 'http://localhost:9999/example/test')
        .with(body: '{"test":"json"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Content-Type' => 'application/json',
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ @client.api_json_post(@uri, 'test' => 'json') }.to_not raise_error
    end

    it 'sends a signed POST with a YAML body' do
      stub_request(:post, 'http://localhost:9999/example/test')
        .with(body: "---\ntest: yaml\n",
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Content-Type' => 'application/x-yaml',
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ @client.api_yaml_post(@uri, 'test' => 'yaml') }.to_not raise_error
    end

    it 'sends a signed PUT with a JSON body' do
      stub_request(:put, 'http://localhost:9999/example/test')
        .with(body: '{"test":"json"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Content-Type' => 'application/json',
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ @client.api_json_put(@uri, 'test' => 'json') }.to_not raise_error
    end

    it 'sends a signed DELETE' do
      stub_request(:delete, 'http://localhost:9999/example/test')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ @client.api_delete(@uri) }.to_not raise_error
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
