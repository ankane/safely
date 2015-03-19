require_relative "test_helper"

class TestSafely < Minitest::Test
  def setup
    Safely.env = "production"
    Safely.report_exception_method = Safely::DEFAULT_EXCEPTION_METHOD
  end

  def test_development_environment
    Safely.env = "development"
    assert_raises(Safely::TestError) do
      safely do
        raise Safely::TestError
      end
    end
  end

  def test_test_environment
    Safely.env = "test"
    assert_raises(Safely::TestError) do
      safely do
        raise Safely::TestError
      end
    end
  end

  def test_production_environment
    exception = Safely::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Safely.report_exception_method = proc { |e| mock.report_exception(e) }
    safely do
      raise exception
    end
    assert mock.verify
  end

  def test_yolo
    exception = Safely::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Safely.report_exception_method = proc { |e| mock.report_exception(e) }
    yolo do
      raise exception
    end
    assert mock.verify
  end

  def test_return_value
    assert_equal 1, safely { 1 }
    assert_equal nil, safely { raise Safely::TestError, "Boom" }
  end

  def test_default
    assert_equal 1, safely(default: 2) { 1 }
    assert_equal 2, safely(default: 2) { raise Safely::TestError, "Boom" }
  end

  def test_only
    assert_equal nil, safely(only: Safely::TestError) { raise Safely::TestError }
    assert_raises(RuntimeError, "Boom") { safely(only: Safely::TestError) { raise "Boom" } }
  end

  def test_only_array
    assert_equal nil, safely(only: [Safely::TestError]) { raise Safely::TestError }
    assert_raises(RuntimeError, "Boom") { safely(only: [Safely::TestError]) { raise "Boom" } }
  end

  def test_except
    assert_raises(Safely::TestError, "Boom") { safely(except: StandardError) { raise Safely::TestError, "Boom" } }
  end

  def test_silence
    safely(silence: StandardError) { raise Safely::TestError, "Boom" }
    assert true
  end

  def test_default_tag
    exception = Safely::TestError.new("Boom")
    safely {raise exception}
    assert_equal "[safely] Boom", exception.message
  end

  def test_no_tag
    Safely.tag = false
    exception = Safely::TestError.new("Boom")
    safely {raise exception}
    assert_equal "Boom", exception.message
    Safely.tag = "safely"
  end

  def test_local_tag
    exception = Safely::TestError.new("Boom")
    safely(tag: "Issue 123"){raise exception}
    assert_equal "[Issue 123] Boom", exception.message
  end

  def test_failsafe
    Safely.report_exception_method = proc { raise "oops" }
    out, err = capture_io do
      safely { raise "boom" }
    end
    assert_equal "FAIL-SAFE RuntimeError: oops\n", err
  end
end
