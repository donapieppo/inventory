require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Inventory
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    config.time_zone = "Rome"
    config.i18n.default_locale = :it

    config.hosts << "ondemand.hpc.unibo.it:3000"

    config.authlevels = {read: 1, manage: 2}

    config.action_mailer.default_url_options = {protocol: "https"}
    config.dm_unibo_common = ActiveSupport::HashWithIndifferentAccess.new config_for(:dm_unibo_common)
  end
end
