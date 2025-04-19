require_relative "test_helper"

class SafelyTest < Minitest::Test
  def test_yolo
    exception = Safely::TestError.new
    mock = Minitest::Mock.new
    mock.expect :report_exception, nil, [exception]
    Safely.report_exception_method = ->(e) { mock.report_exception(e) }
    yolo(tag: false) do
      raise exception
    end
    assert mock.verify
  end

  def test_context
    context = nil
    Safely.report_exception_method = ->(e, ctx) { context = ctx }
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
    Safely.report_exception_method = ->(_) { raise "oops" }
    _, err = capture_io do
      safely { raise "boom" }
    end
    assert_equal "FAIL-SAFE RuntimeError: oops\n", err
  end

  def test_throttle
    assert_count(2) do
      5.times do
        safely throttle: {limit: 2, period: 3600} do
          raise Safely::TestError
        end
      end
    end
  end

  def test_throttle_key
    assert_count(4) do
      5.times do |n|
        safely throttle: {limit: 2, period: 3600, key: "boom#{n % 2}"} do
          raise Safely::TestError
        end
      end
    end
  end

  def test_bad_argument
    assert_raises(ArgumentError) do
      safely(unknown: true) { }
    end
  end

  def test_respond_to?
    refute nil.respond_to?(:safely)
    refute nil.respond_to?(:yolo)
    assert Safely.respond_to?(:safely)
  end
end
