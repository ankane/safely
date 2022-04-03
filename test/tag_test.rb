require_relative "test_helper"

class TagTest < Minitest::Test
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
end
