$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'consul_do'
require 'support/constants_helper'
require 'support/vcr_setup'


RSpec.configure do |config|
  config.include ConstantsHelper

  config.before(:each) do
    overwrite_constant :ARGV, []
    ConsulDo.configure!{}
  end

  config.after(:each) do
    reset_all_constants
  end

end
