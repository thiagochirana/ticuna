# frozen_string_literal: true

module Ticuna
  class Tool
    class << self
      attr_reader :_context

      def context(value = nil)
        if value
          @_context = value
        else
          @_context
        end
      end
    end

    def context
      self.class._context
    end

    def execute(*args)
      raise NotImplementedError, "Tool must implement #execute"
    end
  end
end
