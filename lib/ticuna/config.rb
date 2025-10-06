# frozen_string_literal: true

module Ticuna
  class Config
    attr_accessor :openai_token, :anthropic_token, :deepseek_token, :mistral_token

    def initialize
      @openai_token = nil
      @anthropic_token = nil
      @deepseek_token  = nil
      @mistral_token   = nil
    end

    def openai_token=(token)
      @openai_token = token
    end

    def anthropic_token=(token)
      @anthropic_token = token
    end

    def deepseek_token=(token)
      @deepseek_token = token
    end

    def mistral_token=(token)
      @mistral_token = token
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.config
    self.configuration ||= Config.new
    yield(configuration) if block_given?
    configuration
  end
end
