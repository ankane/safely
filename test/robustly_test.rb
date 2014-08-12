require_relative "test_helper"

class TestRobustly < Minitest::Test

  def setup
    Robustly.env = "production"
    Robustly.report_exception_method = proc {|e| Errbase.report(e) }
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

  def test_return_value
    assert_equal 1, robustly { 1 }
    assert_equal nil, robustly { raise Robustly::TestError }
  end

  def test_default
    assert_equal 1, robustly(default: 2) { 1 }
    assert_equal 2, robustly(default: 2) { raise Robustly::TestError }
  end

  def test_only
    assert_equal nil, robustly(only: Robustly::TestError) { raise Robustly::TestError }
    assert_raises(RuntimeError, "Boom") { robustly(only: Robustly::TestError) { raise RuntimeError.new("Boom") } }
  end

  def test_only_array
    assert_equal nil, robustly(only: [Robustly::TestError]) { raise Robustly::TestError }
    assert_raises(RuntimeError, "Boom") { robustly(only: [Robustly::TestError]) { raise RuntimeError.new("Boom") } }
  end

end
