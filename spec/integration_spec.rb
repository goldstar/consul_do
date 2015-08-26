require 'spec_helper'

# if these cassettes ever need to be recreated, do the following first (FIXME this should be a rake task?)
#
# delete /service/my_key/leader, /service/not_my_key/leader, and /service/no_ones_key/leader
# ssh -L 8500:localhost:8500 consul-host1
# ssh -L 8501:localhost:8500 consul-host2
#
# consul-do -k my_key -p 8500
# consul-do -k not_my_key -p 8501

module ConsulDo
  describe 'Integration' do

    describe '#create_session' do
      it 'returns a session id' do
        VCR.use_cassette("integration/#{ConsulDo.config.key}/create_session") do
          expect(ConsulDo.elect.session).to match(/^.+-.+-.+-.+-.+$/)
          ConsulDo.elect.delete_session
        end
      end
    end

    context 'when I am the leader' do
      before(:each) { ConsulDo.config.key = 'my_key' }

      describe '#get_session_info' do
        it 'should return a hash with a session ID' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/get_session_info") do
            info = ConsulDo.elect.get_session_info(ConsulDo.elect.session)
            expect(info).to be_a(Hash)
            expect(info['ID']).to eq(ConsulDo.elect.session)
            ConsulDo.elect.delete_session
          end
        end
      end

      describe '#cleanup' do
        it 'should delete the session' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/cleanup") do
            session = ConsulDo.elect.session
            ConsulDo.elect.cleanup
            expect{ConsulDo.elect.get_session_info(session)}.to raise_error(/Invalid Session/)
          end
        end
      end

      describe '#is_leader?' do
        it 'should be truthy' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/is_leader") do
            #require 'pry'; binding.pry
            expect(ConsulDo.elect.is_leader?).to be_truthy
            ConsulDo.elect.delete_session
          end
        end
      end

      describe '#get_lock' do
        it 'should fail to get the lock' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/get_lock") do
            ConsulDo.elect.get_lock
            expect(ConsulDo.elect.session_has_lock?).to be_falsey
            ConsulDo.elect.delete_session
          end
        end
      end

    end

    context 'when someone else is the leader' do
      before(:each) { ConsulDo.config.key = 'not_my_key' }

      describe '#get_session_info' do
        it 'should return a hash with a session ID' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/get_session_info") do
            info = ConsulDo.elect.get_session_info(ConsulDo.elect.session)
            expect(info).to be_a(Hash)
            expect(info['ID']).to eq(ConsulDo.elect.session)
            ConsulDo.elect.delete_session
          end
        end
      end

      describe '#cleanup after #get_lock' do
        it 'should delete the session' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/cleanup-after-get_lock") do
            ConsulDo.elect.get_lock
            session = ConsulDo.elect.session
            expect(ConsulDo.elect.session_has_lock?).to be_falsey
            ConsulDo.elect.cleanup
            expect{ConsulDo.elect.get_session_info(session)}.to raise_error(/Invalid Session/)
            ConsulDo.elect.delete_sessions{ |s| s == ConsulDo.config.session_name }
          end
        end
      end

      describe '#is_leader?' do
        it 'should be falsey' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/is_leader") do
            expect(ConsulDo.elect.is_leader?).to be_falsey
            ConsulDo.elect.delete_session
          end
        end
      end
    end

    context 'when no one is the leader' do
      before(:each) { ConsulDo.config.key = 'no_ones_key' }

      describe '#get_session_info' do
        it 'should return a hash with a session ID' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/get_session_info") do
            info = ConsulDo.elect.get_session_info(ConsulDo.elect.session)
            expect(info).to be_a(Hash)
            expect(info['ID']).to eq(ConsulDo.elect.session)
            ConsulDo.elect.delete_session
          end
        end
      end

      describe '#cleanup' do
        it 'should delete the session' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/delete_session") do
            deleted_session = ConsulDo.elect.session

            expect(ConsulDo.elect.delete_session.body).to eq('true')
            expect{ConsulDo.elect.get_session_info(deleted_session)}.to raise_error(/Invalid Session/)
          end
        end
      end

      describe '#is_leader?' do
        it 'should be falsey' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/is_leader") do
            expect(ConsulDo.elect.is_leader?).to be_falsey
            ConsulDo.elect.delete_session
          end
        end
      end

      describe '#get_lock' do
        it 'should get the lock' do
          VCR.use_cassette("integration/#{ConsulDo.config.key}/get_lock") do
            ConsulDo.elect.get_lock
            expect(ConsulDo.elect.session_has_lock?).to be_truthy
            ConsulDo.elect.delete_session
          end
        end
      end

    end

  end
end
