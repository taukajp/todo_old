# frozen_string_literal: true

require "logger"

module Todo
  # ログ出力モジュール
  module Logging
    DEFAULT_LOG_LEVEL = Logger::INFO

    LOG_LEVELS = {
      warn: Logger::WARN,
      info: Logger::INFO,
      debug: Logger::DEBUG
    }.freeze

    @logger = Logger.new($stderr, level: DEFAULT_LOG_LEVEL)
    @logger.formatter = proc do |severity, _datetime, _progname, msg|
      "[#{severity}] #{msg}\n"
    end

    module_function

    # @return [Logger]
    def logger
      @logger
    end
  end
end
