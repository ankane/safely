require_relative "test_helper"

class ServicesTest < Minitest::Test
  def setup
    skip unless defined?(Airbrake)
  end

  def test_default
    Safely.report_exception_method = Safely::DEFAULT_EXCEPTION_METHOD
    Safely.report_exception(RuntimeError.new("Boom"))
  end
end
