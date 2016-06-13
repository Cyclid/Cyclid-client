# rubocop:disable Metrics/LineLength
require 'cli_helper'

describe Cyclid::Cli::Config do
  context 'using the "organization config" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#show' do
      it 'shows a plugin config' do
        config_info = { 'schema' => [{ 'name' => 'setting1',
                                       'type' => 'string',
                                       'description' => 'Setting #1' },
                                     { 'name' => 'setting2',
                                       'type' => 'boolean',
                                       'description' => 'Setting #2' },
                                     { 'name' => 'setting3',
                                       'type' => 'list',
                                       'description' => 'Setting #3' },
                                     { 'name' => 'setting4',
                                       'type' => 'hash-list',
                                       'description' => 'Setting #4' }],
                        'config' => { 'setting1' => 'thing',
                                      'setting2' => 'false',
                                      'setting3' => %w(item1 item2),
                                      'setting4' => [{ 'key1' => 'value1' }, { 'key2' => 'value2' }] } }

        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: config_info.to_json, headers: {})

        expect{ subject.show('test', 'example') }.to_not raise_error
        expect{ subject.show('test', 'example') }.to output(/.*Setting #1:.*thing/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/.*Setting #2:.*true/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/.*Setting #3/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/item1\nitem2/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/.*Setting #4/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/\tkey1: value1\n\tkey2: value2/).to_stdout
      end

      it 'shows a plugin config with an empty list' do
        config_info = { 'schema' => [{ 'name' => 'setting1',
                                       'type' => 'list',
                                       'description' => 'Setting #1' }],
                        'config' => { 'setting1' => [] } }

        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: config_info.to_json, headers: {})

        expect{ subject.show('test', 'example') }.to_not raise_error
        expect{ subject.show('test', 'example') }.to output(/.*Setting #1/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/\tNone/).to_stdout
      end

      it 'shows a plugin config with an empty hash-list' do
        config_info = { 'schema' => [{ 'name' => 'setting1',
                                       'type' => 'hash-list',
                                       'description' => 'Setting #1' }],
                        'config' => { 'setting1' => [] } }

        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: config_info.to_json, headers: {})

        expect{ subject.show('test', 'example') }.to_not raise_error
        expect{ subject.show('test', 'example') }.to output(/.*Setting #1/).to_stdout
        expect{ subject.show('test', 'example') }.to output(/\tNone/).to_stdout
      end

      it 'fails gracefully if the schema contains an unknown type' do
        config_info = { 'schema' => [{ 'name' => 'setting1',
                                       'type' => 'invalid',
                                       'description' => 'Setting #1' }],
                        'config' => { 'setting1' => 'thing' } }

        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: config_info.to_json, headers: {})

        expect{ subject.show('test', 'example') }.to raise_error SystemExit
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.show('test', 'example') }.to raise_error SystemExit
      end
    end

    describe '#edit' do
      # See issue #7
      it 'adds the schema description to the config data' do
        config_info = { 'schema' => [{ 'name' => 'setting1',
                                       'type' => 'string',
                                       'description' => 'Setting #1' },
                                     { 'name' => 'setting2',
                                       'type' => 'boolean',
                                       'description' => 'Setting #2' },
                                     { 'name' => 'setting3',
                                       'type' => 'list',
                                       'description' => 'Setting #3' },
                                     { 'name' => 'setting4',
                                       'type' => 'hash-list',
                                       'description' => 'Setting #4' }],
                        'config' => { 'setting1' => 'thing',
                                      'setting2' => 'false',
                                      'setting3' => %w(item1 item2),
                                      'setting4' => [{ 'key1' => 'value1' }, { 'key2' => 'value2' }] } }

        # The modified hash that will be produced by this method from the above input
        expected_config = { 'setting1' => 'thing',
                            'setting2' => 'false',
                            'setting3' => %w(item1 item2),
                            'setting4' => [{ 'key1' => 'value1' }, { 'key2' => 'value2' }] }

        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: config_info.to_json, headers: {})

        stub_request(:put, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        allow(subject).to receive(:invoke_editor).with(expected_config).and_return({})

        expect{ subject.edit('test', 'example') }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/configs/test/example')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.edit('test', 'example') }.to raise_error SystemExit
      end
    end
  end
end
