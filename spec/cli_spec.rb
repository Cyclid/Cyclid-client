require 'cli_helper'

describe Thor do
  # Expose the private methods
  before :each do
    Thor.send(:public, *Thor.private_instance_methods)
  end

  it 'creates a new client instance' do
    allow_any_instance_of(Thor).to receive(:options).and_return(config: ENV['TEST_CONFIG'])

    expect(subject.client).to be_an_instance_of(Cyclid::Client::Tilapia)
  end

  context 'enabling debug output' do
    it 'sets the log level to FATAL when the debug flag is not set' do
      allow_any_instance_of(Thor).to receive(:options).and_return(debug: false)

      expect(subject.debug?).to be(Logger::FATAL)
    end

    it 'sets the log level to DEBUG when the debug flag is set' do
      allow_any_instance_of(Thor).to receive(:options).and_return(debug: true)

      expect(subject.debug?).to be(Logger::DEBUG)
    end
  end

  context 'invoking a text editor' do
    it 'fails gracefully when the EDITOR environment variable is not set' do
      ENV['EDITOR'] = nil

      expect{ subject.invoke_editor({}) }.to raise_error SystemExit
    end

    # Be aware that this will actually modify the filesystem to create the
    # tempory file
    it 'runs the command defined in EDITOR' do
      test_editor = '/path/to/test/editor'
      ENV['EDITOR'] = test_editor

      allow(subject).to receive(:system).with(/#{test_editor}/).and_return(true)

      expect{ subject.invoke_editor({}) }.to_not raise_error
      expect(subject.invoke_editor({})).to eq({})
    end
  end
end
