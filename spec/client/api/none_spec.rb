# frozen_string_literal: true

require 'client_helper'

describe Cyclid::Client::Api::Basic do
  context 'passing through requests' do
    let :config do
      dbl = instance_double(Cyclid::Client::Config)
      allow(dbl).to receive(:auth).and_return(Cyclid::Client::AuthMethods::AUTH_NONE)
      return dbl
    end

    let :uri do
      URI('http://example.com/example/test')
    end

    subject do
      Cyclid::Client::Api::None.new(config, Logger.new(STDERR))
    end

    it 'does nothing to a request' do
      request = Net::HTTP::Get.new(uri)

      api_request = nil
      expect{ api_request = subject.authenticate_request(request, uri) }.to_not raise_error
      expect(api_request.key?('authorization')).to be(false)
    end
  end
end
