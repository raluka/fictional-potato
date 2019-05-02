# frozen_string_literal: true

$LOAD_PATH.push File.expand_path(__dir__)
require 'api/fetch_campaigns'
require 'campaign/fetch_campaigns'
require 'app/item'
require 'app/out_of_sync_service'
require 'httparty'

module Application
  def self.run!
    url = 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'
    App::OutOfSyncService.call(url)
  end
end

begin
  Application.run!
rescue StandardError => e
  Logger.new(STDOUT).error(e.message)
end
