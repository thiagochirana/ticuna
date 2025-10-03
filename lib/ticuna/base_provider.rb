require "faraday"
require "json"

module Ticuna
  class BaseProvider
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
  end
end
