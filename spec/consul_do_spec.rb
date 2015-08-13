require 'spec_helper'

describe ConsulDo do

  it 'has a version number' do
    expect(ConsulDo::VERSION).not_to be nil
  end

  context 'with ENV["http_proxy"]' do
    describe '.get_key' do

    end

    describe '.get_session_info' do
    end

    describe '.create_session' do
    end

    describe '.delete_session' do
    end

    describe '.get_lock' do
    end
  end

  context 'without ENV["http_proxy"]' do
    describe '.get_key' do
    end

    describe '.get_session_info' do
    end

    describe '.create_session' do
    end

    describe '.delete_session' do
    end

    describe '.get_lock' do
    end
  end

end
