require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CalendarTest1
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.active_record.default_timezone = :local
    #config.time_zone = 'Eastern Time (US & Canada)'
    #config.active_record.default_timezone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    #config.cache_store = :redis_store, 'redis://127.0.0.1:6379/0/cache', { expires_in: 90.minutes }
    config.active_record.raise_in_transactional_callbacks = true
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.active_job.queue_adapter = :delayed_job
    config.action_mailer.default_url_options = { host: "rbacalendar.com" }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        address: "localhost",
        port: 1025
    } 
  end
end
