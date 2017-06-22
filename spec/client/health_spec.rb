# frozen_string_literal: true
require 'client_helper'

describe Cyclid::Client::Health do
  context 'retrieving the API health' do
    let :config do
      { auth: Cyclid::Client::AUTH_NONE,
        server: 'example.com',
        port: 9999 }
    end

    subject do
      Cyclid::Client::Tilapia.new(config)
    end

    before :each do
      allow(File).to receive(:file?).and_return(true)
    end

    it 'retrieves the health status when the server is healthy' do
      stub_request(:get, 'http://example.com:9999/health/status')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby' })
        .to_return(status: 200)

      status = nil
      expect{ status = subject.health_ping }.to_not raise_error
      expect(status).to be true
    end

    it 'retrieves the health status when the server is not healthy' do
      stub_request(:get, 'http://example.com:9999/health/status')
        .with(headers: { 'Accept' => '*/*',
                         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                         'Host' => 'example.com:9999',
                         'User-Agent' => 'Ruby' })
        .to_return(status: 503)

      status = nil
      expect{ status = subject.health_ping }.to_not raise_error
      expect(status).to be false
    end
  end
end
