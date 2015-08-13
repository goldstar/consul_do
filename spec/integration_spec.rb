require 'spec_helper'

# if these cassettes ever need to be recreated, do the following first (FIXME this should be a rake task?)
#
# delete /service/my_key/leader, /service/not_my_key/leader, and /service/no_ones_key/leader
# ssh -L 8500:localhost:8500 consul-host1
# ssh -l 8501:localhost:8500 consul-host2
#
# consul-do -k my_key -p 8500
# consul-do -k not_my_key -p 8501

module ConsulDo
  describe 'Integration' do
    let(:elect) { ConsulDo::Elect.new }
    let(:key_name) { 'my_key' }
    before(:all) { overwrite_constant :ARGV, %w{ -k my_key } }


    context 'with proxy set' do
      pending '#create_session' do
        it 'returns a session id' do
          VCR.use_cassette("integration/#{key_name}/create_session-proxy") do
            #expect(Net::HTTP::Proxy).to receive(:new)
            expect(elect.create_session).to match(/^.+-.+-.+-.+-.+$/)
            elect.delete_session
          end
        end
      end
    end

    context 'without proxy set' do
      describe '#create_session' do
        it 'returns a session id' do
          VCR.use_cassette("integration/#{key_name}/create_session") do
            expect(Net::HTTP).to receive(:new)
            expect(elect.create_session).to match(/^.+-.+-.+-.+-.+$/)
            elect.delete_session
          end
        end
      end

      context 'when I am the leader' do
        let(:key_name) { 'my_key' }
        before(:all) { overwrite_constant :ARGV, %w{ -k my_key } }


        describe '#get_session_info' do
          it 'should return a hash with a session ID' do
            VCR.use_cassette("integration/#{key_name}/get_session_info") do
              info = elect.get_session_info(elect.session)
              expect(info).to be_a(Hash)
              expect(info['ID']).to eq(elect.session)
              elect.delete_session
            end
          end
        end

        describe '#delete_session' do
          it 'should return true' do
            VCR.use_cassette("integration/#{key_name}/delete_session") do
              elect.create_session
              expect(elect.delete_session.body).to eq('true')
            end
          end
        end

        describe '#get_lock' do
          it 'should fail to get the lock' do
            VCR.use_cassette("integration/#{key_name}/get_lock") do
              elect.get_lock
              expect(elect.session_has_lock?).to be_falsey
              elect.delete_session
            end
          end
        end

        describe '#is_leader?' do
          it 'should be truthy' do
            expect(elect.is_leader?).to be_truthy
            elect.delete_session
          end
        end
      end

      context 'when someone else is the leader' do
        let(:key_name) { 'not_my_key' }
        before(:all) { overwrite_constant :ARGV, %w{ -k not_my_key } }

        describe '#get_session_info' do
          it 'should return a hash with a session ID' do
            VCR.use_cassette("integration/#{key_name}/get_session_info") do
              info = elect.get_session_info(elect.session)
              expect(info).to be_a(Hash)
              expect(info['ID']).to eq(elect.session)
              elect.delete_session
            end
          end
        end

        describe '#delete_session' do
          it 'should return true' do
            VCR.use_cassette("integration/#{key_name}/delete_session") do
              elect.create_session
              expect(elect.delete_session.body).to eq('true')
            end
          end
        end

        describe '#get_lock' do
          it 'should fail to get the lock' do
            VCR.use_cassette("integration/#{key_name}/get_lock") do
              elect.get_lock
              expect(elect.session_has_lock?).to be_falsey
              elect.delete_session
            end
          end
        end

        describe '#is_leader?' do
          it 'should be falsey' do
            VCR.use_cassette("integration/#{key_name}/is_leader") do
              expect(elect.is_leader?).to be_falsey
              elect.delete_session
            end
          end
        end
      end

      context 'when no one is the leader' do
        let(:key_name) { 'no_ones_key' }
        before(:all) { overwrite_constant :ARGV, %w{ -k no_ones_key } }

        describe '#get_session_info' do
          it 'should return a hash with a session ID' do
            VCR.use_cassette("integration/#{key_name}/get_session_info") do
              info = elect.get_session_info(elect.session)
              expect(info).to be_a(Hash)
              expect(info['ID']).to eq(elect.session)
              elect.delete_session
            end
          end
        end

        describe '#delete_session' do
          it 'should return true' do
            VCR.use_cassette("integration/#{key_name}/delete_session") do
              elect.create_session
              expect(elect.delete_session.body).to eq('true')
            end
          end
        end

        describe '#get_lock' do
          it 'should fail to get the lock' do
            VCR.use_cassette("integration/#{key_name}/get_lock") do
              elect.get_lock
              expect(elect.session_has_lock?).to be_falsey
              elect.delete_session
            end
          end
        end

        describe '#is_leader?' do
          it 'should be truthy' do
          p key_name
            VCR.use_cassette("integration/#{key_name}/is_leader") do
              expect(elect.is_leader?).to be_truthy
              elect.delete_session
            end
          end
        end
      end

    end
  end
end
