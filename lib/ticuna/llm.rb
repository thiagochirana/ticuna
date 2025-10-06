# frozen_string_literal: true

require "ticuna/providers/openai"
require "ticuna/config"
require "ticuna/response"

module Ticuna
  class LLM
    PROVIDERS_ENV = {
      openai: -> { Ticuna.config.openai_token },
      anthropic: -> { Ticuna.config.anthropic_token },
      deepseek: -> { Ticuna.config.deepseek_token },
      mistral: -> { Ticuna.config.mistral_token }
    }.freeze

    PROVIDERS_CLIENT = {
      openai: -> { Ticuna::Providers::OpenAI.new(api_key: PROVIDERS_ENV[:openai].call) }
      # anthropic: -> { Ticuna::Providers::Anthropic.new(api_key: PROVIDERS_ENV[:anthropic].call) },
      # deepseek: -> { Ticuna::Providers::DeepSeek.new(api_key: PROVIDERS_ENV[:deepseek].call) },
      # mistral: -> { Ticuna::Providers::Mistral.new(api_key: PROVIDERS_ENV[:mistral].call) }
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

    def ask(message, stream: false, model: "gpt-4.1-nano", output_format: :text, &block)
      tool_contexts = @tools.map(&:context).compact.join("\n\n")

      system_message = if tool_contexts.empty?
                         nil
                       else
                         { role: "system", content: "Tools contexts:\n\n#{tool_contexts}" }
                       end

      messages = if system_message
                   [system_message, { role: "user", content: message }]
                 else
                   [{ role: "user", content: message }]
                 end

      Ticuna::Response.new(
        @provider.ask_with_messages(messages, stream: stream, model: model, output_format: output_format, &block)
      )
    end

    private

    def self.detect_provider(provider)
      return provider.to_sym if provider

      valid = PROVIDERS_ENV.reject { |_, env_var| env_var.call&.strip.to_s == "" }

      case valid.size
      when 0
        raise "Provider not found. Define at least one in config/initializers/ticuna.rb"
      when 1
        valid.keys.first
      else
        raise "Multiple LLM APIs providers detected: #{valid.keys.join(", ")}. Define one in Ticuna::LLM.new(provider: :provider_name)."
      end
    end
  end
end
