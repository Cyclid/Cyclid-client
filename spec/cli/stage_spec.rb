# frozen_string_literal: true

require 'cli_helper'

describe Cyclid::Cli::Stage do
  context 'using the "stage" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#list' do
      it 'lists the stages' do
        stage_list = [{ 'name' => 'test', 'version' => '9.9.9' }]

        stub_request(:get, 'http://localhost:9999/organizations/admins/stages')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: stage_list.to_json, headers: {})

        expect{ subject.list }.to_not raise_error
        expect{ subject.list }.to output(/.*test v9.9.9/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/stages')
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
      context 'with a single version' do
        context 'with no steps' do
          it 'shows a stage' do
            stage_info = [{ 'name' => 'test',
                            'version' => '9.9.9',
                            'steps' => [] }]

            stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
              .with(headers: { 'Accept' => '*/*',
                               'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                               'Authorization' => /\AHMAC admin:.*\z/,
                               'Host' => 'localhost:9999',
                               'User-Agent' => 'Ruby',
                               'Date' => /.*/,
                               'X-Hmac-Nonce' => /.*/ })
              .to_return(status: 200, body: stage_info.to_json, headers: {})

            expect{ subject.show('test') }.to_not raise_error
            expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Version:.*9.9.9/).to_stdout
            expect{ subject.show('test') }.to output(/Steps/).to_stdout
          end
        end

        context 'with steps' do
          it 'shows a stage' do
            step_info = { 'action' => 'test',
                          'test' => 'data' }
            stage_info = [{ 'name' => 'test',
                            'version' => '9.9.9',
                            'steps' => [step_info] }]

            stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
              .with(headers: { 'Accept' => '*/*',
                               'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                               'Authorization' => /\AHMAC admin:.*\z/,
                               'Host' => 'localhost:9999',
                               'User-Agent' => 'Ruby',
                               'Date' => /.*/,
                               'X-Hmac-Nonce' => /.*/ })
              .to_return(status: 200, body: stage_info.to_json, headers: {})

            expect{ subject.show('test') }.to_not raise_error
            expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Version:.*9.9.9/).to_stdout
            expect{ subject.show('test') }.to output(/Steps/).to_stdout
            expect{ subject.show('test') }.to output(/Action:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Test:.*data/).to_stdout
          end
        end
      end

      context 'with multiple versions' do
        context 'with no steps' do
          it 'shows a stage' do
            stage_info = [{ 'name' => 'test',
                            'version' => '1.2.3',
                            'steps' => [] },
                          { 'name' => 'test',
                            'version' => '9.9.9',
                            'steps' => [] }]

            stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
              .with(headers: { 'Accept' => '*/*',
                               'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                               'Authorization' => /\AHMAC admin:.*\z/,
                               'Host' => 'localhost:9999',
                               'User-Agent' => 'Ruby',
                               'Date' => /.*/,
                               'X-Hmac-Nonce' => /.*/ })
              .to_return(status: 200, body: stage_info.to_json, headers: {})

            expect{ subject.show('test') }.to_not raise_error
            expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Version:.*1.2.3/).to_stdout
            expect{ subject.show('test') }.to output(/Steps/).to_stdout
            expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Version:.*9.9.9/).to_stdout
            expect{ subject.show('test') }.to output(/Steps/).to_stdout
          end
        end

        context 'with steps' do
          it 'shows a stage' do
            step_info = { 'action' => 'test',

                          'test' => 'data' }
            stage_info = [{ 'name' => 'test',
                            'version' => '1.2.3',
                            'steps' => [step_info] },
                          { 'name' => 'test',
                            'version' => '9.9.9',
                            'steps' => [step_info] }]

            stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
              .with(headers: { 'Accept' => '*/*',
                               'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                               'Authorization' => /\AHMAC admin:.*\z/,
                               'Host' => 'localhost:9999',
                               'User-Agent' => 'Ruby',
                               'Date' => /.*/,
                               'X-Hmac-Nonce' => /.*/ })
              .to_return(status: 200, body: stage_info.to_json, headers: {})

            expect{ subject.show('test') }.to_not raise_error
            expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Version:.*1.2.3/).to_stdout
            expect{ subject.show('test') }.to output(/Steps/).to_stdout
            expect{ subject.show('test') }.to output(/Action:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Test:.*data/).to_stdout
            expect{ subject.show('test') }.to output(/Name:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Version:.*9.9.9/).to_stdout
            expect{ subject.show('test') }.to output(/Steps/).to_stdout
            expect{ subject.show('test') }.to output(/Action:.*test/).to_stdout
            expect{ subject.show('test') }.to output(/Test:.*data/).to_stdout
          end
        end
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
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
      context 'without passing a version' do
        it 'creates a JSON stage' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: '{}',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return('{}')

          subject.options[:json] = true
          expect{ subject.create('test.json') }.to_not raise_error
        end

        it 'detects JSON when the stage filename ends in .json' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: '{}',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return('{}')

          expect{ subject.create('test.json') }.to_not raise_error
        end

        it 'creates a YAML stage' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: 'false',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return('--- false')

          subject.options[:yaml] = true
          expect{ subject.create('test.yaml') }.to_not raise_error
        end

        it 'detects YAML when the stage filename ends in .yaml' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: 'false',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return('--- false')

          expect{ subject.create('test.yaml') }.to_not raise_error
        end

        it 'detects YAML when the stage filename ends in .yml' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: '{"test":"data"}',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return("---\ntest: data")

          expect{ subject.create('test.yml') }.to_not raise_error
        end
      end

      context 'when passing a version' do
        it 'creates a JSON stage' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: '{"version":"9.9.9"}',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return('{}')

          subject.options[:json] = true
          subject.options[:version] = '9.9.9'
          expect{ subject.create('test.json') }.to_not raise_error
        end

        it 'creates a YAML stage' do
          stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
            .with(body: '{"test":"data","version":"9.9.9"}',
                  headers: { 'Accept' => '*/*',
                             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                             'Authorization' => /\AHMAC admin:.*\z/,
                             'Host' => 'localhost:9999',
                             'User-Agent' => 'Ruby',
                             'Date' => /.*/,
                             'X-Hmac-Nonce' => /.*/ })
            .to_return(status: 200, body: '{}', headers: {})

          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return("---\ntest: data")

          subject.options[:yaml] = true
          subject.options[:version] = '9.9.9'
          expect{ subject.create('test.yaml') }.to_not raise_error
        end
      end

      it 'fails gracefully if the file does not exist' do
        allow(File).to receive(:exist?).and_return(false)

        expect{ subject.create('test') }.to raise_error SystemExit
      end

      it 'fails gracefully if it can not detect the file type' do
        allow(File).to receive(:exist?).and_return(true)

        expect{ subject.create('test.test') }.to raise_error SystemExit
      end
    end

    describe '#edit' do
      it 'opens the stage in a text editor' do
        stage_info = [{ 'name' => 'test',
                        'version' => '9.9.9',
                        'steps' => [] }]

        stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: stage_info.to_json, headers: {})

        stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        allow(subject).to receive(:invoke_editor).and_return({})

        expect{ subject.edit('test') }.to_not raise_error
      end

      it 'fails gracefully when the server returns a non-200 response to the GET' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 404, body: '{}', headers: {})

        expect{ subject.edit('test') }.to raise_error SystemExit
      end

      it 'fails gracefully when the server returns a non-200 response to the POST' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/stages/test')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{}', headers: {})

        stub_request(:post, 'http://localhost:9999/organizations/admins/stages')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        allow(subject).to receive(:invoke_editor).and_return({})

        expect{ subject.edit('test') }.to raise_error SystemExit
      end
    end
  end
end
