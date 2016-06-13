require 'client_helper'

describe Cyclid::Client::Stage do
  context 'retrieving stage information' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'returns a list of stages' do
      stage_list = [{ 'name' => 'test', 'version' => '9.9.9' }]

      stub_request(:get, 'http://localhost:9999/organizations/test/stages')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: stage_list.to_json, headers: {})

      stages = []
      expect{ stages = @client.stage_list('test') }.to_not raise_error
      expect(stages).to match_array([{ name: 'test', version: '9.9.9' }])
    end

    it 'returns a valid stage' do
      stub_request(:get, 'http://localhost:9999/organizations/test/stages/example')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      stage = {}
      expect{ stage = @client.stage_get('test', 'example') }.to_not raise_error
      expect(stage['test']).to eq('data')
    end
  end

  context 'creating stages' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'creates a new stage' do
      stub_request(:post, 'http://localhost:9999/organizations/test/stages')
        .with(body: '{"example":"stage"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      stage = { 'example' => 'stage' }

      res = {}
      expect{ res = @client.stage_create('test', stage) }.to_not raise_error
      expect(res['test']).to eq('data')
    end
  end

  context 'modifying a stage' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'modifies the stage' do
      stub_request(:post, 'http://localhost:9999/organizations/test/stages')
        .with(body: '{"example":"stage"}',
              headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Authorization' => /\AHMAC admin:.*\z/,
                         'Host' => 'localhost:9999',
                         'User-Agent' => 'Ruby',
                         'Date' => /.*/,
                         'X-Hmac-Nonce' => /.*/ })
        .to_return(status: 200, body: '{"test": "data"}', headers: {})

      stage = { 'example' => 'stage' }

      res = {}
      expect{ res = @client.stage_modify('test', stage) }.to_not raise_error
      expect(res['test']).to eq('data')
    end
  end
end
