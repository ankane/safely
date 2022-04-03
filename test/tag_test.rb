require_relative "test_helper"

class TagTest < Minitest::Test
  def test_tagged
    assert_message("[safely] Boom") do
      safely { raise Safely::TestError, "Boom" }
    end
  end

  def test_not_tagged
    Safely.tag = false
    assert_message("Boom") do
      safely { raise Safely::TestError, "Boom" }
    end
  ensure
    Safely.tag = true
  end

  def test_local_tag
    assert_message("[hi] Boom") do
      safely(tag: "hi") { raise Safely::TestError, "Boom" }
    end
  end

  def test_report_exception_tag
    assert_message("[safely] Boom") do
      begin
        raise Safely::TestError, "Boom"
      rescue => e
        Safely.report_exception(e)
      end
    end
  end

  def assert_message(expected)
    ex = nil
    Safely.report_exception_method = -> (e) { ex = e }
    yield
    assert_equal expected, ex.message
  end
end
