require 'cli_helper'

describe Cyclid::Cli::AdminOrganization do
  describe '#list' do
    context 'using the "admin organization" commands' do
      before do
        #@cli = Cyclid::Cli::AdminOrganization.new
        subject.options = {config: ENV['TEST_CONFIG']}
      end

      it 'lists the organizations' do
        org_list = [{ 'name' => 'test' }]

        stub_request(:get, 'http://localhost:9999/organizations')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_list.to_json, headers: {})

        expect{ subject.list }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.list }.to raise_error SystemExit
      end
    end
  end
end
