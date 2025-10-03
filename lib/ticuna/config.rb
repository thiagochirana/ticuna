# frozen_string_literal: true

module Ticuna
  class Config
    attr_accessor :openai_token, :anthropic_token, :deepseek_token, :mistral_token

    def initialize
      @openai_token = ENV["OPENAI_API_KEY"]
      @anthropic_token = ENV["ANTHROPIC_API_KEY"]
      @deepseek_token  = ENV["DEEPSEEK_API_KEY"]
      @mistral_token   = ENV["MISTRAL_API_KEY"]
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
