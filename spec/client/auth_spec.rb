# frozen_string_literal: true
require 'client_helper'

describe Cyclid::Client::Auth do
  context 'retrieving an authentication token' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(path: ENV['TEST_CONFIG'])
    end

    it 'retrieves an API token' do
      stub_request(:post, 'http://localhost:9999/token/test')
        .with(body: '"sekrit"',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{}', headers: {})

      expect{ @client.token_get('test', 'sekrit') }.to_not raise_error
    end
  end
end
