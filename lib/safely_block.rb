require "safely/version"
require "errbase"

module Safely
  class << self
    attr_accessor :env, :raise_envs, :tag, :report_exception_method

    def report_exception(e)
      report_exception_method.call(e)
    end
  end

  DEFAULT_EXCEPTION_METHOD = proc do |e|
    e = e.dup # leave original exception unmodified
    e.message.prepend("[safely] ") if e.message && Safely.tag
    Errbase.report(e)
  end

  self.env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
  self.tag = true
  self.report_exception_method = DEFAULT_EXCEPTION_METHOD
  self.raise_envs = %w(development test)

  module Methods
    def safely(options = {})
      yield
    rescue *Array(options[:only] || StandardError) => e
      raise e if Array(options[:except]).any? { |c| e.is_a?(c) }
      raise e if Safely.raise_envs.include?(Safely.env)
      sample = options[:sample]
      if sample ? rand < 1.0 / sample : true
        begin
          Safely.report_exception(e) unless Array(options[:silence]).any? { |c| e.is_a?(c) }
        rescue => e2
          $stderr.puts "FAIL-SAFE #{e2.class.name}: #{e2.message}"
        end
      end
      options[:default]
    end
    alias_method :yolo, :safely
  end
end

Object.send :include, Safely::Methods
