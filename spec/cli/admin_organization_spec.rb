require 'cli_helper'

describe Cyclid::Cli::AdminOrganization do
  context 'using the "admin organization" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#list' do
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
        expect{ subject.list }.to output(/test/).to_stdout
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

    describe '#show' do
      it 'show the details of an organization with no members' do
        pubkey = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw/tWDuC1yMQz0fzMN2zgo/GaF1u6XCYFtHAm2p+VPQT1a2JEcVbCpoO0rv3Ol6LuyqfdNvseriK/3Y7yM3y3aGmr5+Krx8BM7v2QXv0Cy92p7Bkgtg4rJAFv6vF3aHFtj8DqWfInms/nwshkqVi/n2EyBv2XQl/3h+szQ+8DD7rULmDZhBQXPPdRF2zqTOHiFKsEksIkrPHX7GPI2qV4OQ5kKOBEAcAYu+r58LJFKKBOsdI4FEBH3Q4fjGkPTa7Oggr4UvjkOaUbQwnhv/wtaW4sVH7ymZrygnZJlVCyoy5P9ax+CSMrZVW6XCfU8xeMoHsyeo5GAZUHqsgONb6C7QIDAQAB'
        org_info = { 'name' => 'test',
                     'owner_email' => 'test@example.com',
                     'users' => [],
                     'public_key' => pubkey }

        stub_request(:get, 'http://localhost:9999/organizations/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_info.to_json, headers: {})

        expect{ subject.show('test') }.to_not raise_error
        expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
        expect{ subject.show('test') }.to output(/Owner Email:.*test@example.com/).to_stdout
        expect{ subject.show('test') }.to output(/Public Key:.*-----BEGIN PUBLIC KEY-----/).to_stdout
        expect{ subject.show('test') }.to output(/Members:.*\n\s*None/).to_stdout
      end

      it 'show the details of an organization with members' do
        pubkey = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw/tWDuC1yMQz0fzMN2zgo/GaF1u6XCYFtHAm2p+VPQT1a2JEcVbCpoO0rv3Ol6LuyqfdNvseriK/3Y7yM3y3aGmr5+Krx8BM7v2QXv0Cy92p7Bkgtg4rJAFv6vF3aHFtj8DqWfInms/nwshkqVi/n2EyBv2XQl/3h+szQ+8DD7rULmDZhBQXPPdRF2zqTOHiFKsEksIkrPHX7GPI2qV4OQ5kKOBEAcAYu+r58LJFKKBOsdI4FEBH3Q4fjGkPTa7Oggr4UvjkOaUbQwnhv/wtaW4sVH7ymZrygnZJlVCyoy5P9ax+CSMrZVW6XCfU8xeMoHsyeo5GAZUHqsgONb6C7QIDAQAB'
        org_info = { 'name' => 'test',
                     'owner_email' => 'test@example.com',
                     'users' => %w(bob leslie),
                     'public_key' => pubkey }

        stub_request(:get, 'http://localhost:9999/organizations/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_info.to_json, headers: {})

        expect{ subject.show('test') }.to_not raise_error
        expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
        expect{ subject.show('test') }.to output(/Owner Email:.*test@example.com/).to_stdout
        expect{ subject.show('test') }.to output(/Public Key:.*-----BEGIN PUBLIC KEY-----/).to_stdout
        expect{ subject.show('test') }.to output(/Members:.*\n\s*bob.*\n\s*leslie/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.show('test') }.to raise_error SystemExit
      end
    end

    describe '#create' do
      it 'creates a valid organization with no admin specified' do
        stub_request(:post, 'http://localhost:9999/organizations')
          .with(body: '{"name":"test","owner_email":"test@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        expect{ subject.create('test', 'test@example.com') }.to_not raise_error
      end

      it 'creates a valid organization with an admin user specified' do
        stub_request(:post, 'http://localhost:9999/organizations')
          .with(body: '{"name":"test","owner_email":"test@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        stub_request(:put, 'http://localhost:9999/organizations/test')
          .with(body: '{"users":"leslie"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        stub_request(:put, 'http://localhost:9999/organizations/test/members/leslie')
          .with(body: '{"permissions":{"admin":true,"write":true,"read":true}}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:admin] = 'leslie'
        expect{ subject.create('test', 'test@example.com') }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:post, 'http://localhost:9999/organizations')
          .with(body: '{"name":"test","owner_email":"test@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.create('test', 'test@example.com') }.to raise_error SystemExit
      end
    end

    describe '#modify' do
      it 'modifies an organization owners email' do
        stub_request(:put, 'http://localhost:9999/organizations/test')
          .with(body: '{"owner_email":"bob@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"test": "data"}', headers: {})

        subject.options[:email] = 'bob@example.com'
        expect{ subject.modify('test') }.to_not raise_error
      end

      it 'modifies an organizations members' do
        stub_request(:put, 'http://localhost:9999/organizations/test')
          .with(body: '{"users":["leslie"]}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"test": "data"}', headers: {})

        subject.options[:members] = ['leslie']
        expect{ subject.modify('test') }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:put, 'http://localhost:9999/organizations/test')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.modify('test') }.to raise_error SystemExit
      end
    end

    describe '#delete' do
      it 'deletes an organization, when confirmation is given' do
        stub_request(:delete, 'http://localhost:9999/organizations/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        allow($stdin).to receive(:getc).and_return('y')

        expect{ subject.delete('test') }.to_not raise_error
        expect{ subject.delete('test') }.to output(/Delete organization test: are you sure?/).to_stdout
      end

      it 'does not delete an organization, when confirmation is not given' do
        allow($stdin).to receive(:getc).and_return('n')

        expect{ subject.delete('test') }.to raise_error SystemExit
        # expect{ subject.delete('test') }.to output(/Delete organization test: are you sure?/).to_stdout
      end

      it 'deletes an organization, when forced' do
        stub_request(:delete, 'http://localhost:9999/organizations/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:force] = true

        expect{ subject.delete('test') }.to_not raise_error
        expect{ subject.delete('test') }.to_not output(/Delete organization test: are you sure?/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:delete, 'http://localhost:9999/organizations/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        allow($stdin).to receive(:getc).and_return('y')

        expect{ subject.delete('test') }.to raise_error SystemExit
      end
    end
  end
end
