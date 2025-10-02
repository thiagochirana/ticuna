require_relative "../base"

module Ticuna
  module Providers
    class OpenAI < Base
      def initialize(api_key:)
        super(api_key: api_key, base_url: "https://api.openai.com/v1/")
      end

      def ask(message, stream: false, model: "gpt-4.1", &block)
        send_request_to(messages: [{ role: "user", content: message }], stream:, model:, &block)
      end

      private

      def send_request_to(messages:, model: "gpt-4.1", stream: false, &block)
        body = {
          model: model,
          messages: messages,
          stream: stream
        }

        post("chat/completions", body, stream: stream, &block)
      end
    end
  end
end
