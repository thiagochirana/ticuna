require "faraday"
require "json"

module Ticuna
  class Base
    attr_reader :api_key, :base_url, :connection

    def initialize(api_key:, base_url:)
      @api_key = api_key
      @base_url = base_url

      @connection = Faraday.new(
        url: base_url,
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{api_key}"
        }
      )
    end

    def post(path, body, stream: false, &block)
      if stream
        full_text = ""

        connection.post(path) do |req|
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
        resp = connection.post(path, body.to_json)
        JSON.parse(resp.body)
      end
    end
  end
end
