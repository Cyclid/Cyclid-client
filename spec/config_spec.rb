# frozen_string_literal: true

require 'client_helper'

describe Cyclid::Client::Config do
  it 'loads a valid configuration' do
    config = nil
    expect{ config = Cyclid::Client::Config.new(path: ENV['TEST_CONFIG']) }.to_not raise_error
    expect(config.path).to eq(ENV['TEST_CONFIG'])
  end

  it 'loads a valid minimal configuration and sets defaults' do
    test_config = { 'server' => 'example.com',
                    'organization' => 'test',
                    'username' => 'leslie',
                    'secret' => 'sekrit' }

    allow(YAML).to receive(:load_file).and_return(test_config)

    config = nil
    expect{ config = Cyclid::Client::Config.new(path: ENV['TEST_CONFIG']) }.to_not raise_error
    expect(config.server).to eq(test_config['server'])
    expect(config.port).to eq(8361)
    expect(config.organization).to eq(test_config['organization'])
    expect(config.username).to eq(test_config['username'])
    expect(config.secret).to eq(test_config['secret'])
  end

  it 'loads a valid maximal configuration and does not set defaults' do
    test_config = { 'server' => 'example.com',
                    'port' => '4242',
                    'organization' => 'test',
                    'username' => 'leslie',
                    'secret' => 'sekrit' }

    allow(YAML).to receive(:load_file).and_return(test_config)

    config = nil
    expect{ config = Cyclid::Client::Config.new(path: ENV['TEST_CONFIG']) }.to_not raise_error
    expect(config.server).to eq(test_config['server'])
    expect(config.port).to eq(test_config['port'])
    expect(config.organization).to eq(test_config['organization'])
    expect(config.username).to eq(test_config['username'])
    expect(config.secret).to eq(test_config['secret'])
  end

  it 'fails gracefully if the configuration file is invalid' do
    allow(YAML).to receive(:load_file).and_return(nil)

    expect{ Cyclid::Client::Config.new(path: ENV['TEST_CONFIG']) }.to raise_error
  end

  it 'fails gracefully if the configuration file can not be loaded' do
    expect{ Cyclid::Client::Config.new(path: '/invalid/config/file/path') }.to raise_error
  end
end
