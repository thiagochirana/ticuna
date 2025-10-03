# frozen_string_literal: true

require "rails/generators"

module Ticuna
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install Ticuna"

      def copy_initializer
        template "ticuna.rb", "config/initializers/ticuna.rb"
      end
    end
  end
end
