require_relative "test_helper"

class TestSafely < Minitest::Test
  def setup
    Safely.env = "production"
    Safely.tag = true
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
    Safely.report_exception_method = -> (e) { mock.report_exception(e) }
    safely do
      raise exception
    end
    assert mock.verify
  end

  def test_yolo
    exception = Safely::TestError.new
    mock = MiniTest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Safely.report_exception_method = -> (e) { mock.report_exception(e) }
    yolo do
      raise exception
    end
    assert mock.verify
  end

  def test_tagged
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    safely { raise Safely::TestError, "Boom" }
    assert_equal "[safely] Boom", ex.message
  end

  def test_not_tagged
    Safely.tag = false
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    safely { raise Safely::TestError, "Boom" }
    assert_equal "Boom", ex.message
  end

  def test_local_tag
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    safely(tag: "hi") { raise Safely::TestError, "Boom" }
    assert_equal "[hi] Boom", ex.message
  end

  def test_report_exception_tag
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    begin
      raise Safely::TestError, "Boom"
    rescue => e
      Safely.report_exception(e)
    end
    assert_equal "[safely] Boom", ex.message
  end

  def test_context
    context = nil
    Safely.report_exception_method = -> (e, ctx) { context = ctx }
    safely context: {user_id: 123} do
      raise Safely::TestError, "Boom"
    end
    assert_equal ({user_id: 123}), context
  end

  def test_return_value
    assert_equal 1, safely { 1 }
    assert_nil safely { raise Safely::TestError, "Boom" }
  end

  def test_default
    assert_equal 1, safely(default: 2) { 1 }
    assert_equal 2, safely(default: 2) { raise Safely::TestError, "Boom" }
  end

  def test_only
    assert_nil safely(only: Safely::TestError) { raise Safely::TestError }
    assert_raises(RuntimeError, "Boom") { safely(only: Safely::TestError) { raise "Boom" } }
  end

  def test_only_array
    assert_nil safely(only: [Safely::TestError]) { raise Safely::TestError }
    assert_raises(RuntimeError, "Boom") { safely(only: [Safely::TestError]) { raise "Boom" } }
  end

  def test_except
    assert_raises(Safely::TestError, "Boom") { safely(except: StandardError) { raise Safely::TestError, "Boom" } }
  end

  def test_silence
    safely(silence: StandardError) { raise Safely::TestError, "Boom" }
    assert true
  end

  def test_failsafe
    Safely.report_exception_method = -> (_) { raise "oops" }
    _, err = capture_io do
      safely { raise "boom" }
    end
    assert_equal "FAIL-SAFE RuntimeError: oops\n", err
  end

  def test_throttle
    count = 0
    Safely.report_exception_method = -> (_) { count += 1 }
    5.times do
      safely throttle: {limit: 2, period: 3600} do
        raise Safely::TestError
      end
    end
    assert_equal 2, count
  end

  def test_throttle_key
    count = 0
    Safely.report_exception_method = -> (_) { count += 1 }
    5.times do |n|
      safely throttle: {limit: 2, period: 3600, key: "boom#{n % 2}"} do
        raise Safely::TestError
      end
    end
    assert_equal 4, count
  end

  def test_bad_argument
    assert_raises(ArgumentError) do
      safely(unknown: true) { }
    end
  end
end
