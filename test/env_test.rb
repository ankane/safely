require_relative "test_helper"

class EnvTest < Minitest::Test
  def test_development
    Safely.env = "development"
    assert_raises(Safely::TestError) do
      safely do
        raise Safely::TestError
      end
    end
  end

  def test_test
    Safely.env = "test"
    assert_raises(Safely::TestError) do
      safely do
        raise Safely::TestError
      end
    end
  end

  def test_production
    exception = Safely::TestError.new
    reported_exceptions = []
    Safely.report_exception_method = ->(e) { reported_exceptions << e }
    safely(tag: false) do
      raise exception
    end
    assert_equal [exception], reported_exceptions
  end
end
