require 'cli_helper'

describe Cyclid::Cli::User do
  context 'using the "user" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#show' do
      it 'shows the details of a user with no organizations' do
        test_user = { 'username' => 'bob',
                      'email' => 'bob@example.com',
                      'organizations' => [] }

        stub_request(:get, 'http://localhost:9999/users/admin')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_user.to_json, headers: {})

        expect{ subject.show }.to_not raise_error
        expect{ subject.show }.to output(/Username:.*bob/).to_stdout
        expect{ subject.show }.to output(/Email:.*bob@example.com/).to_stdout
        expect{ subject.show }.to output(/Organizations.*\n\s*None/).to_stdout
      end

      it 'shows the details of a user with organizations' do
        test_user = { 'username' => 'bob',
                      'email' => 'bob@example.com',
                      'organizations' => ['test'] }

        stub_request(:get, 'http://localhost:9999/users/admin')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_user.to_json, headers: {})

        expect{ subject.show }.to_not raise_error
        expect{ subject.show }.to output(/Username:.*bob/).to_stdout
        expect{ subject.show }.to output(/Email:.*bob@example.com/).to_stdout
        expect{ subject.show }.to output(/Organizations.*\n\s*test/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/users/admin')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.show }.to raise_error SystemExit
      end
    end

    describe '#modify' do
      it 'modifies a users email' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(body: '{"email":"bob@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:email] = 'bob@example.com'
        expect{ subject.modify }.to_not raise_error
      end

      it 'modifies a users password' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(body: /{"password":".*"}/,
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:password] = 'm1lkb0ne'
        expect{ subject.modify }.to_not raise_error
      end

      it 'modifies a users secret' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(body: '{"secret":"sekrit"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:secret] = 'sekrit'
        expect{ subject.modify }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.modify }.to raise_error SystemExit
      end
    end

    describe '#passwd' do
      it 'changes the password when the inputs match' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(body: /{"password":".*"}/,
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        allow($stdin).to receive(:noecho).and_return('m1lkb0ne')
        expect{ subject.passwd }.to_not raise_error
      end

      it 'does not change the password when the inputs do not match' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(body: /{"password":".*"}/,
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        allow($stdin).to receive(:noecho).and_return(SecureRandom.hex)
        expect{ subject.passwd }.to raise_error SystemExit
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:put, 'http://localhost:9999/users/admin')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        allow($stdin).to receive(:noecho).and_return('m1lkb0ne')
        expect{ subject.passwd }.to raise_error SystemExit
      end
    end
  end
end
