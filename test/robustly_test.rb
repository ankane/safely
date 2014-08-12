require_relative "test_helper"

class TestRobustly < Minitest::Test

  def setup
    Robustly.env = "production"
  end

  def test_robustly_development_environment
    Robustly.env = "development"
    assert_raises(Robustly::TestError) do
      robustly do
        raise Robustly::TestError
      end
    end
  end

  def test_robustly_test_environment
    Robustly.env = "test"
    assert_raises(Robustly::TestError) do
      robustly do
        raise Robustly::TestError
      end
    end
  end

  def test_robustly_production_environment
    exception = Robustly::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Robustly.report_exception_method = proc {|e| mock.report_exception(e) }
    robustly do
      raise exception
    end
    assert mock.verify
  end

  def test_yolo
    exception = Robustly::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Robustly.report_exception_method = proc {|e| mock.report_exception(e) }
    yolo do
      raise exception
    end
    assert mock.verify
  end

end
