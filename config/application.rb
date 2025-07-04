require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module QuickMendan
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "Tokyo"

    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framework :rspec
    end
  end
end
