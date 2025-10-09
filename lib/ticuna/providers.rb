# frozen_string_literal: true

module Ticuna
  module Providers
    MODELS = {
      gpt_4_1: "gpt-4.1",
      gpt_4_1_nano: "gpt-4.1-nano",
      gpt_4_1_mini: "gpt-4.1-mini",
      gpt_5: "gpt-5",
      gpt_5_nano: "gpt-5-nano",
      gpt_5_mini: "gpt-5-mini"
    }.freeze

    ENVS = {
      openai: -> { Ticuna.config.openai_token }
      # anthropic: -> { Ticuna.config.anthropic_token },
      # deepseek: -> { Ticuna.config.deepseek_token },
      # mistral: -> { Ticuna.config.mistral_token }
    }.freeze

    CLIENTS = {
      openai: -> { Ticuna::Providers::OpenAI.new(api_key: ENVS[:openai].call) }
      # anthropic: -> { Ticuna::Providers::Anthropic.new(api_key: ENVS[:anthropic].call) },
      # deepseek: -> { Ticuna::Providers::DeepSeek.new(api_key: ENVS[:deepseek].call) },
      # mistral: -> { Ticuna::Providers::Mistral.new(api_key: ENVS[:mistral].call) }
    }.freeze
  end
end
