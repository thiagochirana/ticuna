# frozen_string_literal: true

require "json"
require "ticuna/providers"

module Ticuna
  class Response
    attr_reader :data, :errors, :parsed, :raw_response, :response, :provider

    def initialize(raw, provider: nil)
      @provider = provider
      @raw_response = raw
      @parsed =
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

      @data = deep_symbolize_keys(@parsed)
      error_payload =
        if @parsed.is_a?(Hash)
          @parsed["error"] || @parsed[:error] || []
        else
          []
        end
      @errors = deep_symbolize_keys(error_payload)
      @response = resolve_response
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

    def errors?
      !errors.empty?
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
        self.class.new(value, provider: provider)
      when Array
        value.map { |v| wrap(v) }
      else
        value
      end
    end

    def resolve_response
      from_provider = extract_from_provider
      return from_provider unless blank?(from_provider)

      fallback =
        if @data.is_a?(Hash)
          @data[:content] || @data[:response]
        end
      return fallback unless blank?(fallback)

      @parsed if @parsed.is_a?(String)
    end

    def blank?(value)
      value.respond_to?(:empty?) ? value.empty? : !value
    end

    def extract_from_provider
      return unless provider

      extractor = Ticuna::Providers::RESPONSE_EXTRACTORS[provider]
      extractor&.call(@data)
    end
  end
end
