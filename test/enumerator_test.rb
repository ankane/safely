require_relative "test_helper"

class World
  include Enumerable

  def each(&block)
    3.times(&block)
  end

  def hello
    safely do
      raise Safely::TestError
    end
  end
end

class EnumeratorTest < Minitest::Test
  def test_works
    count = 0
    Safely.report_exception_method = -> (_) { count += 1 }
    3.times.safely do |i|
      raise Safely::TestError if i.even?
    end
    assert_equal 2, count
  end

  def test_chaining
    error = assert_raises(ArgumentError) do
      3.times.safely.each { }
    end
    assert_equal "tried to call safely on Enumerator without a block", error.message
  end

  def test_options
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    1.times.safely(tag: "hi") { raise Safely::TestError, "Boom" }
    assert_equal "[hi] Boom", ex.message
  end

  def test_default
    result =
      3.times.map.safely(default: "error") do |i|
        raise Safely::TestError if i.odd?
        i
      end
    assert_equal [0, "error", 2], result
  end

  def test_map_before
    result =
      3.times.map.safely do |i|
        raise Safely::TestError if i.odd?
        i
      end
    assert_equal [0, nil, 2], result
  end

  def test_map_after
    skip "Fails when safely is chainable"

    result =
      3.times.safely.map do |i|
        raise Safely::TestError if i.odd?
        i
      end

    assert_equal [0, nil, 2], result
  end

  def test_enumerable
    count = 0
    Safely.report_exception_method = -> (_) { count += 1 }
    World.new.hello
    assert_equal 1, count
  end

  def test_respond_to?
    refute [].respond_to?(:safely)
    assert [].each.respond_to?(:safely)
  end
end
