# frozen_string_literal: true

require 'cli_helper'

describe Cyclid::Cli::Job do
  context 'using the "job" commands' do
    before do
      subject.options = { config: ENV['TEST_CONFIG'] }
    end

    describe '#submit' do
      it 'submits a JSON job' do
        stub_request(:post, 'http://localhost:9999/organizations/admins/jobs')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"job_id": 1}', headers: {})

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('{}')

        subject.options[:json] = true
        expect{ subject.submit('test-job.json') }.to_not raise_error
        expect{ subject.submit('test-job.json') }.to output(/Job:.*/).to_stdout
      end

      it 'detects JSON when job filename ends in .json' do
        stub_request(:post, 'http://localhost:9999/organizations/admins/jobs')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"job_id": 1}', headers: {})

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('{}')

        expect{ subject.submit('test-job.json') }.to_not raise_error
      end

      it 'submits a YAML job' do
        stub_request(:post, 'http://localhost:9999/organizations/admins/jobs')
          .with(body: '--- false',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/x-yaml',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"job_id": 1}', headers: {})

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('--- false')

        subject.options[:yaml] = true
        expect{ subject.submit('test-job.yaml') }.to_not raise_error
      end

      it 'detects YAML when job filename ends in .yaml' do
        stub_request(:post, 'http://localhost:9999/organizations/admins/jobs')
          .with(body: '--- false',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/x-yaml',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"job_id": 1}', headers: {})

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('--- false')

        expect{ subject.submit('test-job.yaml') }.to_not raise_error
      end

      it 'detects YAML when job filename ends in .yml' do
        stub_request(:post, 'http://localhost:9999/organizations/admins/jobs')
          .with(body: '--- false',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/x-yaml',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"job_id": 1}', headers: {})

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('--- false')

        expect{ subject.submit('test-job.yml') }.to_not raise_error
      end

      it 'fails gracefully if the type can not be infered from the filename' do
        allow(File).to receive(:exist?).and_return(true)

        expect{ subject.submit('test-job.fail') }.to raise_error SystemExit
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:post, 'http://localhost:9999/organizations/admins/jobs')
          .with(body: '{}',
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Content-Type' => 'application/json',
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('{}')

        expect{ subject.submit('test-job.json') }.to raise_error SystemExit
      end
    end

    describe '#show' do
      it 'shows a job with a valid start & end time' do
        test_job = { 'id' => 1,
                     'job_name' => 'test',
                     'job_version' => '9.9.9',
                     'started' => Time.now,
                     'ended' => Time.now,
                     'status' => 1 }

        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_job.to_json, headers: {})

        expect{ subject.show('1') }.to_not raise_error
        expect{ subject.show('1') }.to output(/Job:.*1/).to_stdout
        expect{ subject.show('1') }.to output(/Name:.*test/).to_stdout
        expect{ subject.show('1') }.to output(/Version:.*9.9.9/).to_stdout
        expect{ subject.show('1') }.to output(/Started:.*/).to_stdout
        expect{ subject.show('1') }.to output(/Ended:.*/).to_stdout
        expect{ subject.show('1') }.to output(/Status:.*Waiting/).to_stdout
      end

      it 'shows a job with an empty start & end time' do
        test_job = { 'id' => 1,
                     'job_name' => 'test',
                     'job_version' => '9.9.9',
                     'started' => nil,
                     'ended' => nil,
                     'status' => 1 }

        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_job.to_json, headers: {})

        expect{ subject.show('1') }.to_not raise_error
        expect{ subject.show('1') }.to output(/Job:.*1/).to_stdout
        expect{ subject.show('1') }.to output(/Name:.*test/).to_stdout
        expect{ subject.show('1') }.to output(/Version:.*9.9.9/).to_stdout
        expect{ subject.show('1') }.to output(/Started:.*/).to_stdout
        expect{ subject.show('1') }.to output(/Ended:.*/).to_stdout
        expect{ subject.show('1') }.to output(/Status:.*Waiting/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        expect{ subject.show('1') }.to raise_error SystemExit
      end
    end

    describe '#status' do
      it 'shows a job status' do
        test_job = { 'status' => 1 }

        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1/status')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: test_job.to_json, headers: {})

        expect{ subject.status('1') }.to_not raise_error
        expect{ subject.status('1') }.to output(/Status:.*Waiting/).to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1/status')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        expect{ subject.status('1') }.to raise_error SystemExit
      end
    end

    describe '#log' do
      it 'shows a job log' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1/log')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 200, body: '{"log":"this is a log"}', headers: {})

        expect{ subject.log('1') }.to_not raise_error
        expect{ subject.log('1') }.to output("this is a log\n").to_stdout
      end

      it 'fails gracefully when the server returns a non-200 response' do
        stub_request(:get, 'http://localhost:9999/organizations/admins/jobs/1/log')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => /\AHMAC admin:.*\z/,
                           'Host' => 'localhost:9999',
                           'User-Agent' => 'Ruby',
                           'Date' => /.*/,
                           'X-Hmac-Nonce' => /.*/ })
          .to_return(status: 500, body: '{}', headers: {})

        expect{ subject.log('1') }.to raise_error SystemExit
      end
    end
  end
end
