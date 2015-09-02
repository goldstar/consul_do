require 'spec_helper'
require 'webmock/rspec'

describe ConsulDo do

  it 'has a version number' do
    expect(ConsulDo::VERSION).not_to be nil
  end

  context 'with proxy' do
    before(:each) do
      stub_request(:any, "www.example.com")
      ConsulDo.config.http_proxy = 'http://proxy.example.com:1234'
    end

    describe 'http_get' do
      it 'uses the proxy' do
        expect(Net::HTTP).to receive(:Proxy).and_return Net::HTTP.Proxy()
        expect(Net::HTTP).to receive(:get_response)
        ConsulDo.http_get('http://www.example.com:80/testing')
      end
    end

    describe 'http_put' do
      it 'uses the proxy' do
        expect(Net::HTTP).to receive(:Proxy).and_return Net::HTTP.Proxy()
        expect_any_instance_of(Net::HTTP).to receive(:send_request)
        ConsulDo.http_put('http://www.example.com:80/testing')
      end
    end
  end

  context 'without proxy' do
    before(:each) do
      stub_request(:any, "www.example.com")
      ConsulDo.config.http_proxy = nil
    end

    describe 'http_get' do
      it "doesn't use the proxy" do
        expect(Net::HTTP).not_to receive(:Proxy)
        expect(Net::HTTP).to receive(:get_response)
        ConsulDo.http_get('http://www.example.com:80/testing')
      end
    end

    describe 'http_put' do
      it "doesn't use the proxy" do
        expect(Net::HTTP).not_to receive(:Proxy)
        expect_any_instance_of(Net::HTTP).to receive(:send_request)
        ConsulDo.http_put('http://www.example.com:80/testing')
      end
    end
  end
end
