require 'client_helper'

describe Cyclid::Client::Job do
  context 'retrieving job information' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'returns a job for a valid organization and id' do
      stub_request(:get, 'http://localhost:9999/organizations/test/jobs/1')
        .with(:headers => {'Accept'=>'*/*',
                          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Authorization'=>/\AHMAC admin:.*\z/,
                          'Host'=>'localhost:9999',
                          'User-Agent'=>'Ruby',
                          'Date'=>/.*/,
                          'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => {test: 'data'}.to_json, :headers => {})

      job = {}
      expect{ job = @client.job_get('test', 1) }.to_not raise_error
      expect( job['test'] ).to eq('data')
    end

    it 'returns a job status for a valid organization and id' do
      stub_request(:get, 'http://localhost:9999/organizations/test/jobs/1/status')
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => {test: 'data'}.to_json, :headers => {})

      status = {}
      expect{ status = @client.job_status('test', 1) }.to_not raise_error
      expect( status['test'] ).to eq('data')
    end

    it 'returns a job log for a valid organization and id' do
      stub_request(:get, 'http://localhost:9999/organizations/test/jobs/1/log')
        .with(:headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => {test: 'data'}.to_json, :headers => {})

      log = {}
      expect{ log = @client.job_log('test', 1) }.to_not raise_error
      expect( log['test'] ).to eq('data')
    end
  end

  context 'submitting a new job' do
    before :all do
      @client = Cyclid::Client::Tilapia.new(ENV['TEST_CONFIG'])
    end

    it 'submits a JSON job to a valid organization' do
      stub_request(:post, "http://localhost:9999/organizations/test/jobs")
        .with(:body => '{}',
              :headers => {'Accept'=>'*/*',
                           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>/\AHMAC admin:.*\z/,
                           'Content-Type'=>'application/json',
                           'Host'=>'localhost:9999',
                           'User-Agent'=>'Ruby',
                           'Date'=>/.*/,
                           'X-Hmac-Nonce'=>/.*/})
        .to_return(:status => 200, :body => "{}", :headers => {})

      expect{ @client.job_submit('test', '{}', 'json') }.to_not raise_error
    end

    it 'submits a YAML job to a valid organization' do
       stub_request(:post, "http://localhost:9999/organizations/test/jobs")
         .with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Authorization'=>/\AHMAC admin:.*\z/,
                            'Content-Type'=>'application/x-yaml',
                            'Host'=>'localhost:9999',
                            'User-Agent'=>'Ruby',
                            'Date'=>/.*/,
                            'X-Hmac-Nonce'=>/.*/})
         .to_return(:status => 200, :body => '{}', :headers => {})

      expect{ @client.job_submit('test', '', 'yaml') }.to_not raise_error
    end

    it 'raises an error if the job is not in YAML or JSON' do
      expect do
        @client.job_submit('test', '', 'unsuported')
      end.to raise_error(RuntimeError, 'Unknown job format unsuported')
    end
  end
end
