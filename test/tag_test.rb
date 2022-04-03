require_relative "test_helper"

class TagTest < Minitest::Test
  def test_default
    assert_message("[safely] Boom") do
      safely { raise Safely::TestError, "Boom" }
    end
  end

  def test_global
    Safely.tag = false
    assert_message("Boom") do
      safely { raise Safely::TestError, "Boom" }
    end
  ensure
    Safely.tag = true
  end

  def test_local
    assert_message("[hi] Boom") do
      safely(tag: "hi") { raise Safely::TestError, "Boom" }
    end
  end

  def test_report_exception
    assert_message("[safely] Boom") do
      begin
        raise Safely::TestError, "Boom"
      rescue => e
        Safely.report_exception(e)
      end
    end
  end

  private

  def assert_message(expected)
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    yield
    assert_equal expected, ex.message
  end
end
