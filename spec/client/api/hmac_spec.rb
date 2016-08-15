require 'client_helper'

describe Cyclid::Client::Api::Hmac do
  context 'signing requests' do
    let :config do
      dbl = instance_double(Cyclid::Client::Config)
      allow(dbl).to receive(:auth).and_return(Cyclid::Client::AuthMethods::AUTH_HMAC)
      allow(dbl).to receive(:username).and_return('test')
      allow(dbl).to receive(:secret).and_return('sekrit')
      return dbl
    end

    let :uri do
      URI('http://example.com/example/test')
    end

    subject do
      Cyclid::Client::Api::Hmac.new(config, Logger.new(STDERR))
    end

    it 'signs a GET request' do
      request = Net::HTTP::Get.new(uri)

      api_request = nil
      expect{ api_request = subject.authenticate_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('x-hmac-algorithm')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'signs a POST request' do
      request = Net::HTTP::Post.new(uri)

      api_request = nil
      expect{ api_request = subject.authenticate_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('x-hmac-algorithm')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'signs a PUT request' do
      request = Net::HTTP::Put.new(uri)

      api_request = nil
      expect{ api_request = subject.authenticate_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('x-hmac-algorithm')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'signs a DELETE request' do
      request = Net::HTTP::Delete.new(uri)

      api_request = nil
      expect{ api_request = subject.authenticate_request(request, uri) }.to_not raise_error
      expect(api_request.key?('x-hmac-nonce')).to be(true)
      expect(api_request.key?('x-hmac-algorithm')).to be(true)
      expect(api_request.key?('authorization')).to be(true)
      expect(api_request.key?('date')).to be(true)
    end

    it 'rejects non-GET/PUT/POST/DELETE requests' do
      request = Net::HTTP::Patch.new(uri)

      expect{ subject.authenticate_request(request, uri) }.to raise_error
    end
  end

  context 'performing signed requests' do
    let :config do
      dbl = instance_double(Cyclid::Client::Config)
      allow(dbl).to receive(:auth).and_return(Cyclid::Client::AuthMethods::AUTH_HMAC)
      allow(dbl).to receive(:server).and_return('http://example.com')
      allow(dbl).to receive(:port).and_return(9999)
      allow(dbl).to receive(:username).and_return('test')
      allow(dbl).to receive(:secret).and_return('sekrit')
      return dbl
    end

    let :uri do
      URI('http://example.com:9999/example/test')
    end

    subject do
      allow(Cyclid::Client::Config).to receive(:new).and_return(config)
      Cyclid::Client::Tilapia.new(path: nil)
    end

    it 'sends a signed GET' do
      stub_request(:get, 'http://example.com:9999/example/test')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC test:.*\z/,
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/,
                         'X-Hmac-Algorithm' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      res = nil
      expect{ res = subject.api_get(uri) }.to_not raise_error
      expect(res['test']).to eq('data')
    end

    it 'sends a signed POST with a JSON body' do
      stub_request(:post, 'http://example.com:9999/example/test')
        .with(body: '{"test":"json"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC test:.*\z/,
                         'Content-Type' => 'application/json',
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/,
                         'X-Hmac-Algorithm' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ subject.api_json_post(uri, 'test' => 'json') }.to_not raise_error
    end

    it 'sends a signed POST with a YAML body' do
      stub_request(:post, 'http://example.com:9999/example/test')
        .with(body: "---\ntest: yaml\n",
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC test:.*\z/,
                         'Content-Type' => 'application/x-yaml',
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/,
                         'X-Hmac-Algorithm' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ subject.api_yaml_post(uri, 'test' => 'yaml') }.to_not raise_error
    end

    it 'sends a signed PUT with a JSON body' do
      stub_request(:put, 'http://example.com:9999/example/test')
        .with(body: '{"test":"json"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC test:.*\z/,
                         'Content-Type' => 'application/json',
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/,
                         'X-Hmac-Algorithm' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ subject.api_json_put(uri, 'test' => 'json') }.to_not raise_error
    end

    it 'sends a signed DELETE' do
      stub_request(:delete, 'http://example.com:9999/example/test')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC test:.*\z/,
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/,
                         'X-Hmac-Algorithm' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      expect{ subject.api_delete(uri) }.to_not raise_error
    end
  end
end
