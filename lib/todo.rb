# frozen_string_literal: true

require_relative "todo/version"
require_relative "todo/core_ext/string"

def __p(path)
  File.join(__dir__, *path.split("/"))
end

module Todo
  class Error < StandardError; end

  autoload :Logging, __p("todo/logging")
  autoload :Task, __p("todo/task")
  autoload :DB, __p("todo/db")
  autoload :Command, __p("todo/command")

  class << self
    # A convenience method for Todo::Logging.logger.
    #
    # @return [Logger]
    def logger
      Todo::Logging.logger
    end
  end
end

undef __p
