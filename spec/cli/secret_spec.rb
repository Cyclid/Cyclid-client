# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
require 'cli_helper'

describe Cyclid::Cli::Secret do
  context 'using the "secret" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
      allow($stdin).to receive(:noecho).and_return('sekrit')
    end

    describe '#encrypt' do
      it 'encrypts a secret with an organization key' do
        pubkey = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw/tWDuC1yMQz0fzMN2zgo/GaF1u6XCYFtHAm2p+VPQT1a2JEcVbCpoO0rv3Ol6LuyqfdNvseriK/3Y7yM3y3aGmr5+Krx8BM7v2QXv0Cy92p7Bkgtg4rJAFv6vF3aHFtj8DqWfInms/nwshkqVi/n2EyBv2XQl/3h+szQ+8DD7rULmDZhBQXPPdRF2zqTOHiFKsEksIkrPHX7GPI2qV4OQ5kKOBEAcAYu+r58LJFKKBOsdI4FEBH3Q4fjGkPTa7Oggr4UvjkOaUbQwnhv/wtaW4sVH7ymZrygnZJlVCyoy5P9ax+CSMrZVW6XCfU8xeMoHsyeo5GAZUHqsgONb6C7QIDAQAB'
        org_info = { 'public_key' => pubkey }

        stub_request(:get, 'http://localhost:9999/organizations/admins')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_info.to_json, headers: {})

        expect{ subject.encrypt }.to_not raise_error
        expect{ subject.encrypt }.to output(/Secret:.*/).to_stdout
      end

      it 'fails gracefully if encryption fails' do
        org_info = { 'public_key' => 'invalid' }

        stub_request(:get, 'http://localhost:9999/organizations/admins')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_info.to_json, headers: {})

        expect{ subject.encrypt }.to raise_error SystemExit
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.encrypt }.to raise_error SystemExit
      end
    end
  end
end
