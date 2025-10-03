# frozen_string_literal: true

require_relative "../base_provider"

module Ticuna
  module Providers
    class OpenAI < BaseProvider
      def initialize(api_key:)
        super(api_key: api_key, base_url: "https://api.openai.com/v1/")
      end

      def ask(message, stream: false, model: "gpt-4.1-nano", &block)
        send_request_to(messages: [{ role: "user", content: message }], stream:, model:, &block)
      end

      private

      def send_request_to(messages:, model: nil, stream: false, &block)
        body = {
          model: model,
          messages: messages,
          stream: stream
        }

        post("chat/completions", body, stream: stream, &block)
      end

      def post(path, body, stream: false, &block)
        if stream
          full_text = String.new

          @connection.post(path) do |req|
            req.body = body.to_json

            req.options.on_data = proc do |chunk, _bytes|
              chunk.each_line do |line|
                next unless line.start_with?("data:")

                data = line.sub("data:", "").strip
                next if data.empty? || data == "[DONE]"

                begin
                  json = JSON.parse(data)
                rescue JSON::ParserError
                  next
                end

                delta = json.dig("choices", 0, "delta", "content")
                full_text << delta if delta

                yield json if block_given?
              end
            end
          end

          {
            "id" => "streamed_completion_#{Time.now.to_i}",
            "object" => "chat.completion",
            "model" => body[:model],
            "choices" => [
              {
                "index" => 0,
                "message" => {
                  "role" => "assistant",
                  "content" => full_text
                },
                "finish_reason" => "stop"
              }
            ]
          }
        else
          resp = @connection.post(path, body.to_json)
          JSON.parse(resp.body)
        end
      end
    end
  end
end
