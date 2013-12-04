module Rake
  module Admin
    # Task configuration error.
    class TaskConfigurationError < RuntimeError
    end

    # Operating system environment error.
    class EnvironmentError < RuntimeError
    end
  end
end