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
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Safely.report_exception_method = -> (e) { mock.report_exception(e) }
    safely do
      raise exception
    end
    assert mock.verify
  end
end
