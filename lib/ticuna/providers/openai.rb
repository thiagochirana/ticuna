# frozen_string_literal: true

require_relative "../base_provider"

module Ticuna
  module Providers
    class OpenAI < BaseProvider
      def initialize(api_key:)
        super(api_key: api_key, base_url: "https://api.openai.com/v1/")
        @response = String.new
        @raw_response = String.new
      end

      def ask(message, stream: false, model: "gpt-4.1-nano", output_format: :text, &block)
        send_request_to(
          messages: [{ role: "user", content: message }],
          stream:,
          model:,
          output_format:,
          &block
        )
      end

      def ask_with_messages(messages, stream: false, model: "gpt-4.1-nano", output_format: :text, &block)
        send_request_to(messages:, stream:, model:, output_format:, &block)
      end

      private

      def send_request_to(messages:, model: nil, stream: false, output_format: :text, &block)
        raise ArgumentError, "Invalid output_format: #{output_format}" unless %i[text json].include?(output_format)

        body = {
          model: model,
          messages: messages,
          stream: stream
        }

        body[:response_format] = { type: "json_object" } if output_format == :json

        post("chat/completions", body, stream: stream, &block)
      rescue Faraday::BadRequestError => e
        raise "response_format not supported by #{model}" unless e.message.include?("response_format")
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

          @response = full_text
          @raw_response = {
            "id" => "streamed_completion_#{Time.now.to_i}",
            "object" => "chat.completion",
            "model" => body[:model],
            "choices" => [
              {
                "index" => 0,
                "message" => { "role" => "assistant", "content" => full_text },
                "finish_reason" => "stop"
              }
            ]
          }
        else
          resp = @connection.post(path, body.to_json)
          @raw_response = JSON.parse(resp.body)
          @response = @raw_response.dig("choices", 0, "message", "content")
        end

        @raw_response
      end
      attr_reader :response, :raw_response
    end
  end
end
