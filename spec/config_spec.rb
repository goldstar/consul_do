require 'spec_helper'

module ConsulDo
  describe Config do
    let(:config) { ConsulDo::Config.new }

    describe '#parse' do
      it 'should fail when no key is given' do
        overwrite_constant :ARGV, []
        expect{ config.parse }.to raise_error(/Required options not found/)
      end

      it 'should default to localhost:8500' do
        overwrite_constant :ARGV, %w{ -k foo }
        opts = config.parse
        expect(opts['host']).to eq('localhost')
        expect(opts['port']).to eq('8500')
      end

      it 'should allow key to be specified' do
        overwrite_constant :ARGV, %w{ -k foo }
        expect(config.parse['key']).to eq('foo')
      end 

      it 'should allow host and port overrides' do
        overwrite_constant :ARGV, %w{ -k foo -h bar -p 123 }
        opts = config.parse
        expect(opts['host']).to eq('bar')
        expect(opts['port']).to eq('123')
      end

    end

    describe '#proxy' do
      context 'with proxy set by ENV' do
        it 'should return a URI of http_proxy' do
          overwrite_constant :ENV, {'http_proxy' => 'http://foo:123'}
          overwrite_constant :ARGV, %w{ -k foo }
          expect(config.proxy).to be_a_kind_of(URI)
          expect(config.proxy.host).to eq('foo')
          expect(config.proxy.port).to eq(123)
        end
      end

      context 'with proxy set on command line' do
        it 'should return a URI of http_proxy' do
          overwrite_constant :ARGV, %w{ -k foo --http_proxy http://foo:123}
          expect(config.proxy).to be_a_kind_of(URI)
          expect(config.proxy.host).to eq('foo')
          expect(config.proxy.port).to eq(123)
        end
      end

      context 'with no proxy set' do
        it 'should return a nil URI' do
          overwrite_constant :ENV, {}
          overwrite_constant :ARGV, %w{ -k foo }
          expect(config.proxy).to be_a_kind_of(URI)
          expect(config.proxy.host).to eq(nil)
          expect(config.proxy.port).to eq(nil)
        end
      end

    end

  end
end
