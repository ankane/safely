require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

module Safely
  class TestError < StandardError; end
end

class Minitest::Test
  def setup
    Safely.env = "production"
    Safely.tag = true
    Safely.report_exception_method = Safely::DEFAULT_EXCEPTION_METHOD
  end
end
