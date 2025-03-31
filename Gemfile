# frozen_string_literal: true

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.29-stable" }.freeze

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-extra_user_fields", path: "."

gem "bootsnap", "~> 1.7"
gem "country_select", "~> 4.0"
gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 3.3.1"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "rubocop-factory_bot", "!= 2.26.0", require: false
  gem "rubocop-rspec_rails", "!= 2.29.0", require: false
end
