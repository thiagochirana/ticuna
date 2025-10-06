# frozen_string_literal: true

require "json"

module Ticuna
  class Response
    attr_reader :data

    def initialize(raw)
      parsed =
        case raw
        when String
          begin
            JSON.parse(raw)
          rescue JSON::ParserError
            { content: raw }
          end
        when Hash
          raw
        else
          raise ArgumentError, "Ticuna::Response only accepts Hash or String, received: #{raw.class}"
        end

      @data = deep_symbolize_keys(parsed)
    end

    def [](key)
      @data[key.to_sym]
    end

    def to_h
      @data
    end

    def to_s
      @data.inspect
    end

    def method_missing(name, *args, &block)
      value = @data[name]
      return wrap(value) if @data.key?(name)
      super
    end

    def respond_to_missing?(name, include_private = false)
      @data.key?(name) || super
    end

    private

    def deep_symbolize_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(k, v), h|
          h[k.to_sym] = deep_symbolize_keys(v)
        end
      when Array
        obj.map { |v| deep_symbolize_keys(v) }
      else
        obj
      end
    end

    def wrap(value)
      case value
      when Hash
        self.class.new(value)
      when Array
        value.map { |v| wrap(v) }
      else
        value
      end
    end
  end
end
