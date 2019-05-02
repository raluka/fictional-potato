# frozen_string_literal: true

$LOAD_PATH.push File.expand_path(__dir__)

module Application
  def self.run!
    Logger.new(STDOUT).info("Application run")
  end
end

begin
  Application.run!
rescue StandardError => e
  Logger.new(STDOUT).error(e.message)
end
