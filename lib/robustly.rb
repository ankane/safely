require "robustly/version"
require "errbase"

module Robustly
  class << self
    attr_accessor :env, :tag, :report_exception_method

    def report_exception(e)
      report_exception_method.call(e)
    end
  end

  DEFAULT_EXCEPTION_METHOD = proc do |e|
    e = e.dup # leave original exception unmodified
    e.message.prepend("[safely] ") if e.message && Robustly.tag
    Errbase.report(e)
  end

  self.env = ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
  self.tag = true
  self.report_exception_method = DEFAULT_EXCEPTION_METHOD

  module Methods
    def safely(options = {})
      class_names = Array(options[:only] || StandardError)
      begin
        yield
      rescue *class_names => e
        raise e if %w(development test).include?(Robustly.env)
        if options[:throttle] ? rand < 1.0 / options[:throttle] : true
          begin
            Robustly.report_exception(e)
          rescue => e2
            $stderr.puts "FAIL-SAFE #{e2.class.name}: #{e2.message}"
          end
        end
        options[:default]
      end
    end
    alias_method :yolo, :safely
    alias_method :robustly, :safely # legacy
  end
end

Object.send :include, Robustly::Methods
