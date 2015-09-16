require 'spec_helper'
require 'webmock/rspec'

describe ConsulDo do
  before(:all) { VCR.turn_off! }
  after(:all) { VCR.turn_on! }

  it 'has a version number' do
    expect(ConsulDo::VERSION).not_to be nil
  end

  context 'with proxy' do
    before(:each) do
      stub_request(:any, /www.example.com/)
      ConsulDo.config.http_proxy = 'http://proxy.example.com:1234'
    end

    describe 'http_get' do
      it 'uses the proxy' do
        expect(ConsulDo.config).to receive(:net_http_proxy).and_return(Net::HTTP.Proxy())
        ConsulDo.http_get('http://www.example.com:80/testing')
      end
    end

    describe 'http_put' do
      it 'uses the proxy' do
        expect(ConsulDo.config).to receive(:net_http_proxy).and_return(Net::HTTP.Proxy())
        ConsulDo.http_put('http://www.example.com:80/testing')
      end
    end
  end

  context 'without proxy' do
    before(:each) do
      stub_request(:any, /www.example.com/)
      ConsulDo.config.http_proxy = nil
    end

    describe 'http_get' do
      it "doesn't use the proxy" do
        expect(ConsulDo.config).not_to receive(:net_http_proxy)
        ConsulDo.http_get('http://www.example.com:80/testing')
      end
    end

    describe 'http_put' do
      it "doesn't use the proxy" do
        expect(ConsulDo.config).not_to receive(:net_http_proxy)
        ConsulDo.http_put('http://www.example.com:80/testing')
      end
    end
  end
end
