require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: ENV.fetch("BROWSER") { :chrome }.to_sym, screen_size: [420, 740]
end
