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
    Safely.report_exception_method = -> (_) { }
  end

  def assert_count(expected)
    count = 0
    Safely.report_exception_method = -> (_) { count += 1 }
    yield
    assert_equal expected, count
  end
end
