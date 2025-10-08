# frozen_string_literal: true

require "ticuna/providers/openai"
require "ticuna/providers"
require "ticuna/config"
require "ticuna/response"

module Ticuna
  class LLM
    def self.new(provider = nil)
      provider_key = detect_provider(provider)
      provider_client = Ticuna::Providers::CLIENTS[provider_key].call
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

    def ask(message, stream: false, model: :gpt_4_1, output_format: :text, &block)
      tool_contexts = @tools.map(&:context).compact.join("\n\n")

      system_message = if tool_contexts.empty?
                         nil
                       else
                         { role: "developer", content: tool_contexts }
                       end

      messages = if system_message
                   [system_message, { role: "user", content: message }]
                 else
                   [{ role: "user", content: message }]
                 end

      model_string = resolve_model(model)

      Ticuna::Response.new(
        @provider.ask_with_messages(messages, stream: stream, model: model_string, output_format: output_format, &block)
      )
    end

    private

    def resolve_model(model)
      return model.to_s unless model.is_a?(Symbol)
      return model if Ticuna::Providers::MODELS.key?(model)

      available_models = Ticuna::Providers::MODELS.flat_map { |provider, models| 
        models.keys.map { |m| ":#{m} (#{provider})" } 
      }.join(", ")

      raise "Model ':#{model}' not found. Available models: #{available_models}"
    end

    class << self
      private

      def detect_provider(provider)
        return provider.to_sym if provider

        valid = Ticuna::Providers::ENVS.reject { |_, env_var| env_var.call&.strip.to_s == "" }

        case valid.size
        when 0
          raise "Provider not found. Define at least one in config/initializers/ticuna.rb"
        when 1
          valid.keys.first
        else
          raise "Multiple LLM APIs providers detected: #{valid.keys.join(", ")}.\nDefine one in Ticuna::LLM.new(model: :provider_name)."
        end
      end
    end
  end
end
