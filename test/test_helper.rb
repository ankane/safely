require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

module Safely
  class TestError < StandardError; end
end
