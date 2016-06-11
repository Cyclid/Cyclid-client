require 'cli_helper'

describe Cyclid::Cli::Organization do
  context 'using the "organization" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#show' do
      it 'shows an organization with no members' do
        pubkey = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw/tWDuC1yMQz0fzMN2zgo/GaF1u6XCYFtHAm2p+VPQT1a2JEcVbCpoO0rv3Ol6LuyqfdNvseriK/3Y7yM3y3aGmr5+Krx8BM7v2QXv0Cy92p7Bkgtg4rJAFv6vF3aHFtj8DqWfInms/nwshkqVi/n2EyBv2XQl/3h+szQ+8DD7rULmDZhBQXPPdRF2zqTOHiFKsEksIkrPHX7GPI2qV4OQ5kKOBEAcAYu+r58LJFKKBOsdI4FEBH3Q4fjGkPTa7Oggr4UvjkOaUbQwnhv/wtaW4sVH7ymZrygnZJlVCyoy5P9ax+CSMrZVW6XCfU8xeMoHsyeo5GAZUHqsgONb6C7QIDAQAB'
        org_info = { 'name' => 'test',
                     'owner_email' => 'test@example.com',
                     'users' => [],
                     'public_key' => pubkey }

        stub_request(:get, 'http://localhost:9999/organizations/admins')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_info.to_json, headers: {})

        expect{ subject.show }.to_not raise_error
        expect{ subject.show }.to output(/Name:.*test/).to_stdout
        expect{ subject.show }.to output(/Owner Email:.*test@example.com/).to_stdout
        expect{ subject.show }.to output(/Public Key:.*-----BEGIN PUBLIC KEY-----/).to_stdout
        expect{ subject.show }.to output(/Members:.*\n\s*None/).to_stdout
      end

      it 'shows an organization with members' do
        pubkey = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw/tWDuC1yMQz0fzMN2zgo/GaF1u6XCYFtHAm2p+VPQT1a2JEcVbCpoO0rv3Ol6LuyqfdNvseriK/3Y7yM3y3aGmr5+Krx8BM7v2QXv0Cy92p7Bkgtg4rJAFv6vF3aHFtj8DqWfInms/nwshkqVi/n2EyBv2XQl/3h+szQ+8DD7rULmDZhBQXPPdRF2zqTOHiFKsEksIkrPHX7GPI2qV4OQ5kKOBEAcAYu+r58LJFKKBOsdI4FEBH3Q4fjGkPTa7Oggr4UvjkOaUbQwnhv/wtaW4sVH7ymZrygnZJlVCyoy5P9ax+CSMrZVW6XCfU8xeMoHsyeo5GAZUHqsgONb6C7QIDAQAB'
        org_info = { 'name' => 'test',
                     'owner_email' => 'test@example.com',
                     'users' => %w(bob leslie),
                     'public_key' => pubkey }

        stub_request(:get, 'http://localhost:9999/organizations/admins')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: org_info.to_json, headers: {})

        expect{ subject.show }.to_not raise_error
        expect{ subject.show }.to output(/Name:.*test/).to_stdout
        expect{ subject.show }.to output(/Owner Email:.*test@example.com/).to_stdout
        expect{ subject.show }.to output(/Public Key:.*-----BEGIN PUBLIC KEY-----/).to_stdout
        expect{ subject.show }.to output(/Members:.*\n\s*bob.*\n\s*leslie/).to_stdout
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

        expect{ subject.show }.to raise_error SystemExit
      end
    end

    describe '#modify' do
      it 'modifies an organization owners email' do
        stub_request(:put, 'http://localhost:9999/organizations/admins')
          .with(body: '{"owner_email":"bob@example.com"}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        subject.options[:email] = 'bob@example.com'
        expect{ subject.modify }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:put, 'http://localhost:9999/organizations/admins')
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

        expect{ subject.modify }.to raise_error SystemExit
      end
    end

    describe '#list' do
      before :each do
        allow(Dir).to receive(:glob).and_return(%w(/path/to/org1 /path/to/org2))
        allow(File).to receive(:symlink?).and_return(false)
        allow(File).to receive(:file?).and_return(true)
      end

      it 'lists the available organizations' do
        allow(YAML).to receive(:load_file).and_return(YAML.load_file(ENV['TEST_CONFIG']))

        expect{ subject.list }.to_not raise_error
        expect{ subject.list }.to output(/.*(org1|org2)/).to_stdout
        expect{ subject.list }.to output(/.*Server:.*localhost/).to_stdout
        expect{ subject.list }.to output(/.*Organization:.*admins/).to_stdout
        expect{ subject.list }.to output(/.*Username:.*admin/).to_stdout
      end

      it 'fails gracefully if the configuration file can not be parsed' do
        allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT)

        expect{ subject.list }.to raise_error SystemExit
      end

      # XXX There are some strange exception paths here; requires some investigation
      if false
        it 'fails gracefully if the configuration file is incorrect' do
          allow(YAML).to receive(:load_file).and_return({})

          expect{ subject.list }.to output(/Failed to load config file (org1|org2)/).to_stderr
        end
      end
    end

    describe '#use' do
      before :each do
        # Ensure the test don't modify the running config
        allow(File).to receive(:delete).and_return(true)
        allow(File).to receive(:symlink).and_return(true)
      end

      it 'shows the current configuration when it is not a symlink' do
        allow(File).to receive(:symlink?).and_return(false)

        subject.options[:config] = 'org1'

        expect{ subject.use }.to_not raise_error
        expect{ subject.use }.to output(/org1/).to_stdout
      end

      it 'shows the current configuration when it is a symlink' do
        allow(File).to receive(:symlink?).and_return(true)
        allow(File).to receive(:readlink).and_return('/path/to/org2')

        subject.options[:config] = 'org1'

        expect{ subject.use }.to_not raise_error
        expect{ subject.use }.to output(/org2/).to_stdout
      end

      it 'selects a new configuration' do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return(YAML.load_file(ENV['TEST_CONFIG']))

        expect{ subject.use('org') }.to_not raise_error
      end

      it 'fails gracefully if the configuration file is invalid' do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({})

        expect{ subject.use('org') }.to raise_error SystemExit
      end
    end
  end
end
