require 'spec_helper'

module ConsulDo
  describe Config do
    let(:config) { ConsulDo::Config.new }
    describe '#parse' do

      it 'should allow key to be specified' do

        overwrite_constant :ARGV, %w{ -k foo }
        config.parse
        expect(config.key).to eq('foo')
        
      end 

      it 'should default to localhost:8500' do
        overwrite_constant :ARGV, []
        config.parse
        expect(config.host).to eq('localhost')
        expect(config.port).to eq('8500')
      end

      it 'should allow host and port overrides' do
        overwrite_constant :ARGV, %w{ -h bar -p 123 }
        config.parse
        expect(config.host).to eq('bar')
        expect(config.port).to eq('123')
      end

    end

    describe '#proxy' do
      context 'with proxy set by ENV' do
        it 'should return a URI of http_proxy' do
          overwrite_constant :ENV, {'http_proxy' => 'http://foo:123'}
          overwrite_constant :ARGV, []

          config.parse
          expect(config.proxy).to be_a_kind_of(URI)
          expect(config.proxy.port).to eq(123)
        end
      end

      context 'with proxy set on command line' do
        it 'should return a URI of http_proxy' do
          overwrite_constant :ARGV, %w{ --http_proxy http://foo:123}
          config.parse
          expect(config.proxy).to be_a_kind_of(URI)
          expect(config.proxy.port).to eq(123)
        end
      end

      context 'with no proxy set' do
        it 'should return a nil URI' do
          overwrite_constant :ENV, {}
          config.parse
          expect(config.proxy.host).to eq(nil)
          expect(config.proxy.port).to eq(nil)
        end
      end

    end

  end
end
