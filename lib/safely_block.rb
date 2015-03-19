require "errbase"

module Safely
  VERSION = "0.1.0"

  class << self
    attr_accessor :env, :raise_envs, :tag, :report_exception_method

    def report_exception(e)
      report_exception_method.call(e)
    end
  end

  DEFAULT_EXCEPTION_METHOD = proc do |e|
    Errbase.report(e)
  end

  self.env = ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
  self.tag = "safely"
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
          e = prepend_with_tag(e, options[:tag])
          Safely.report_exception(e) unless Array(options[:silence]).any? { |c| e.is_a?(c) }
        rescue => e2
          $stderr.puts "FAIL-SAFE #{e2.class.name}: #{e2.message}"
        end
      end
      options[:default]
    end
    alias_method :yolo, :safely

    private
    
    def prepend_with_tag(e, tag_option)
      e = e.dup # leave original exception unmodified
      tag = tag_option || Safely.tag
      e.message.prepend("[#{tag}] ") if e.message && tag
      e
    end
  end
end

Object.send :include, Safely::Methods
