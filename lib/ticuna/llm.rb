# frozen_string_literal: true

require "ticuna/providers/openai"

module Ticuna
  class LLM
    PROVIDERS_ENV = {
      openai: "OPENAI_API_KEY"
    }.freeze

    PROVIDERS_CLIENT = {
      openai: -> { Ticuna::Providers::OpenAI.new(api_key: ENV["OPENAI_API_KEY"]) }
    }.freeze

    def self.for(provider = nil)
      if provider.nil?
        valid = PROVIDERS_ENV.reject { |_, env_var| ENV[env_var]&.strip.to_s == "" }

        case valid.size
        when 0
          raise "Provider not found. Define at least one ENV with token."
        when 1
          provider = valid.keys.first
          puts "Using provider detected automatically: #{provider}"
        else
          puts "Multiple providers detected:"
          valid.each_with_index { |(prov, _), idx| puts "#{idx + 1}) #{prov}" }
          print "Choose a provider by number: "
          choice = gets.to_i
          provider = valid.keys[choice - 1] || raise("Invalid choice")
        end
      end

      client_proc = PROVIDERS_CLIENT[provider.to_sym] or raise ArgumentError, "Provider not found: #{provider}"
      client_proc.call
    end

    def self.new(provider = nil)
      self.for(provider)
    end
  end
end
