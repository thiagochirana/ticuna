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

    def self.new(provider = nil)
      provider_key = detect_provider(provider)
      provider_client = PROVIDERS_CLIENT[provider_key].call
      new_instance = allocate
      new_instance.send(:initialize_llm, provider_client)
      new_instance
    end

    def initialize_llm(provider_client)
      @provider = provider_client
      @tools = []
    end

    def tool(klass)
      @tools << klass.new
      self
    end

    def ask(message, stream: false, model: "gpt-4.1-nano", &block)
      tool_contexts = @tools.map(&:context).compact.join("\n\n")

      system_message = {
        role: "system",
        content: "Você é um agente com acesso às seguintes ferramentas:\n\n#{tool_contexts}"
      }

      messages = [system_message, { role: "user", content: message }]
      @provider.ask_with_messages(messages, stream: stream, model: model, &block)
    end

    private

    def self.detect_provider(provider)
      return provider.to_sym if provider

      valid = PROVIDERS_ENV.reject { |_, env_var| ENV[env_var]&.strip.to_s == "" }

      case valid.size
      when 0
        raise "Provider not found. Define at least one ENV with token."
      when 1
        valid.keys.first
      else
        puts "Multiple providers detected:"
        valid.each_with_index { |(prov, _), idx| puts "#{idx + 1}) #{prov}" }
        print "Choose a provider by number: "
        choice = gets.to_i
        valid.keys[choice - 1] || raise("Invalid choice")
      end
    end
  end
end
