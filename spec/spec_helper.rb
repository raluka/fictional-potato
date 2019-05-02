# frozen_string_literal: true

require 'application'
require 'webmock/rspec'
require 'factory_bot'
require 'pry'

SPEC_ROOT = File.join(__dir__)
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.filter_run_excluding pending: true

  config.order = 'random'
  Kernel.srand config.seed
  config.include WebMock::API
  config.include FactoryBot::Syntax::Methods
  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
