require 'spec_helper'
require 'webmock/rspec'

module ConsulDo
  describe Elect do
    before(:all) { VCR.turn_off! }
    after(:all) { VCR.turn_on! }

    before(:each) do
      stub_request(:any, /localhost:8500/)
    end

    context 'with a token' do
      before(:each) do
        ConsulDo.config.token = 'foo-bar-baz'
      end

      describe '#get_key' do
        it 'should use the token' do
          ConsulDo.elect.get_key
          expect(WebMock).to have_requested(:get, %r|/v1/kv/|).
            with(:query => hash_including({'token' => 'foo-bar-baz'}) ).once
        end
      end

      describe '#get_lock' do
        it 'should use the token' do
          allow(ConsulDo.elect).to receive(:session).and_return('fake-session')
          ConsulDo.elect.get_lock
          expect(WebMock).to have_requested(:put, %r|/v1/kv/|).
            with(:query => hash_including({'token' => 'foo-bar-baz'}) ).once
        end
      end
    end

    context 'without a token' do
      describe '#get_key' do
        it 'should not use a token' do
          ConsulDo.elect.get_key
          expect(WebMock).not_to have_requested(:get, %r|/v1/kv/|).
            with(:query => hash_including({'token' => /./}) )
          expect(WebMock).to have_requested(:get, %r|/v1/kv/|).once
        end
      end

      describe '#get_lock' do
        it 'should not use a token' do
          allow(ConsulDo.elect).to receive(:session).and_return('fake-session')
          ConsulDo.elect.get_lock
          expect(WebMock).not_to have_requested(:put, %r|/v1/kv/|).
            with(:query => hash_including({'token' => /./}) )
          expect(WebMock).to have_requested(:put, %r|/v1/kv/|).once
        end
      end
    end
  end
end
