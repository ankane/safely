require_relative "test_helper"

class TestRobustly < Minitest::Test
  def setup
    Robustly.env = "production"
    Robustly.report_exception_method = Robustly::DEFAULT_EXCEPTION_METHOD
  end

  def test_safely_development_environment
    Robustly.env = "development"
    assert_raises(Robustly::TestError) do
      safely do
        raise Robustly::TestError
      end
    end
  end

  def test_safely_test_environment
    Robustly.env = "test"
    assert_raises(Robustly::TestError) do
      safely do
        raise Robustly::TestError
      end
    end
  end

  def test_safely_production_environment
    exception = Robustly::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Robustly.report_exception_method = proc { |e| mock.report_exception(e) }
    safely do
      raise exception
    end
    assert mock.verify
  end

  def test_yolo
    exception = Robustly::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Robustly.report_exception_method = proc { |e| mock.report_exception(e) }
    yolo do
      raise exception
    end
    assert mock.verify
  end

  def test_return_value
    assert_equal 1, safely { 1 }
    assert_equal nil, safely { raise Robustly::TestError, "Boom" }
  end

  def test_default
    assert_equal 1, safely(default: 2) { 1 }
    assert_equal 2, safely(default: 2) { raise Robustly::TestError, "Boom" }
  end

  def test_only
    assert_equal nil, safely(only: Robustly::TestError) { raise Robustly::TestError }
    assert_raises(RuntimeError, "Boom") { safely(only: Robustly::TestError) { raise RuntimeError, "Boom" } }
  end

  def test_only_array
    assert_equal nil, safely(only: [Robustly::TestError]) { raise Robustly::TestError }
    assert_raises(RuntimeError, "Boom") { safely(only: [Robustly::TestError]) { raise RuntimeError, "Boom" } }
  end

  def test_except
    assert_raises(Robustly::TestError, "Boom") { safely(except: StandardError) { raise Robustly::TestError, "Boom" } }
  end

  def test_silence
    safely(silence: StandardError) { raise Robustly::TestError, "Boom" }
    assert true
  end

  def test_failsafe
    Robustly.report_exception_method = proc { raise "oops" }
    out, err = capture_io do
      safely { raise "boom" }
    end
    assert_equal "FAIL-SAFE RuntimeError: oops\n", err
  end
end
