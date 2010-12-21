require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Explainpmt
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.active_record.observers = :audit_observer
    config.filter_parameters += [:password, :password_confirmation]
  end
end
