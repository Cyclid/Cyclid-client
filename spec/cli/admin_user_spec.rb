require 'cli_helper'

describe Cyclid::Cli::AdminUser do
  context 'using the "admin user" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#list' do
      it 'lists the users' do
        user_list = [{ 'username' => 'bob' }]

        stub_request(:get, 'http://localhost:9999/users')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: user_list.to_json, headers: {})

        expect{ subject.list }.to_not raise_error
        expect{ subject.list }.to output("bob\n").to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/users')
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
      it 'shows the details of a user with no organizations' do
        test_user = { 'username' => 'bob',
                      'email' => 'bob@example.com',
                      'organizations' => [] }

        stub_request(:get, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_user.to_json, headers: {})

        expect{ subject.show('bob') }.to_not raise_error
        expect{ subject.show('bob') }.to output(/Username:.*bob/).to_stdout
        expect{ subject.show('bob') }.to output(/Email:.*bob@example.com/).to_stdout
        expect{ subject.show('bob') }.to output(/Organizations.*\n\s*None/).to_stdout
      end

      it 'shows the details of a user with organizations' do
        test_user = { 'username' => 'bob',
                      'email' => 'bob@example.com',
                      'organizations' => ['test'] }

        stub_request(:get, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_user.to_json, headers: {})

        expect{ subject.show('bob') }.to_not raise_error
        expect{ subject.show('bob') }.to output(/Username:.*bob/).to_stdout
        expect{ subject.show('bob') }.to output(/Email:.*bob@example.com/).to_stdout
        expect{ subject.show('bob') }.to output(/Organizations.*\n\s*test/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.show('bob') }.to raise_error SystemExit
      end
    end

    describe '#creates' do
      it 'creates a user with no password or secret' do
        stub_request(:post, 'http://localhost:9999/users')
          .with(body: '{"username":"leslie","email":"leslie@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        expect{ subject.create('leslie', 'leslie@example.com') }.to_not raise_error
      end

      it 'creates a user with an initial password' do
        stub_request(:post, 'http://localhost:9999/users')
          .with(body: /{"username":"leslie","email":"leslie@example.com","password":".*"}/,
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:password] = 'm1lkb0ne'
        expect{ subject.create('leslie', 'leslie@example.com') }.to_not raise_error
      end

      it 'creates a user with an initial secret' do
        stub_request(:post, 'http://localhost:9999/users')
          .with(body: '{"username":"leslie","email":"leslie@example.com","secret":"sekrit"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:secret] = 'sekrit'
        expect{ subject.create('leslie', 'leslie@example.com') }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:post, 'http://localhost:9999/users')
          .with(body: '{"username":"leslie","email":"leslie@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        expect{ subject.create('leslie', 'leslie@example.com') }.to raise_error SystemExit
      end
    end

    describe '#modify' do
      it 'modifies a users email' do
        stub_request(:put, 'http://localhost:9999/users/bob')
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
        expect{ subject.modify('bob') }.to_not raise_error
      end

      it 'modifies a users password' do
        stub_request(:put, 'http://localhost:9999/users/bob')
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
        expect{ subject.modify('bob') }.to_not raise_error
      end

      it 'modifies a users secret' do
        stub_request(:put, 'http://localhost:9999/users/bob')
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
        expect{ subject.modify('bob') }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:put, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.modify('bob') }.to raise_error SystemExit
      end
    end

    describe '#passwd' do
      it 'changes the password when the inputs match' do
        stub_request(:put, 'http://localhost:9999/users/bob')
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
        expect{ subject.passwd('bob') }.to_not raise_error
      end

      it 'does not change the password when the inputs do not match' do
        stub_request(:put, 'http://localhost:9999/users/bob')
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
        expect{ subject.passwd('bob') }.to raise_error SystemExit
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:put, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        allow($stdin).to receive(:noecho).and_return('m1lkb0ne')
        expect{ subject.passwd('bob') }.to raise_error SystemExit
      end
    end

    describe '#delete' do
      it 'deletes a user, when confirmation is given' do
        stub_request(:delete, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        allow($stdin).to receive(:getc).and_return('y')

        expect{ subject.delete('bob') }.to_not raise_error
        expect{ subject.delete('bob') }.to output(/Delete user bob: are you sure?/).to_stdout
      end

      it 'does not delete a user, when confirmation is not given' do
        allow($stdin).to receive(:getc).and_return('n')

        expect{ subject.delete('bob') }.to raise_error SystemExit
        # expect{ subject.delete('bob') }.to output(/Delete user bob: are you sure?/).to_stdout
      end

      it 'deletes a user, when forced' do
        stub_request(:delete, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:force] = true

        expect{ subject.delete('bob') }.to_not raise_error
        expect{ subject.delete('bob') }.to_not output(/Delete user bob: are you sure?/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:delete, 'http://localhost:9999/users/bob')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        allow($stdin).to receive(:getc).and_return('y')

        expect{ subject.delete('bob') }.to raise_error SystemExit
      end
    end
  end
end
