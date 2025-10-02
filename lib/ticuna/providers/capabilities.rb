# frozen_string_literal: true

module Ticuna
  module Providers
    module Capabilities
      module_function

      LLMS = {
        gpt41: /^gpt-4\.1(?!-(?:mini|nano))/,
        gpt41_mini: /^gpt-4\.1-mini/,
        gpt41_nano: /^gpt-4\.1-nano/,
        gpt4: /^gpt-4(?:-\d{6})?$/,
        gpt4_turbo: /^gpt-4(?:\.5)?-(?:\d{6}-)?(preview|turbo)/,
        gpt4o: /^gpt-4o(?!-(?:mini|audio|realtime|transcribe|tts|search))/,
        gpt5: /^gpt-5/,
        gpt5_mini: /^gpt-5-mini/,
        gpt5_nano: /^gpt-5-nano/
      }.freeze

      PRICES = {
        gpt5: { input: 1.25, output: 10.0, cached_input: 0.125 },
        gpt5_mini: { input: 0.25, output: 2.0, cached_input: 0.025 },
        gpt5_nano: { input: 0.05, output: 0.4, cached_input: 0.005 },
        gpt41: { input: 2.0, output: 8.0, cached_input: 0.5 },
        gpt41_mini: { input: 0.4, output: 1.6, cached_input: 0.1 },
        gpt41_nano: { input: 0.1, output: 0.4 },
        gpt4: { input: 10.0, output: 30.0 },
        gpt4_turbo: { input: 10.0, output: 30.0 },
        gpt4o: { input: 2.5, output: 10.0 },
        gpt4o_mini: { input: 0.15, output: 0.6 }
      }.freeze
    end
  end
end
