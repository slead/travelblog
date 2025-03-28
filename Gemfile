source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.1'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'pg', '~> 0.20'
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'bootstrap', '~> 4.0.0.beta'
gem 'devise'
gem 'execjs'
gem 'flickraw', '~> 0.9.9'
gem 'friendly_id', '~> 5.2', '>= 5.2.3'
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'
gem 'geocoder'
gem 'google-analytics-rails', '~> 1.1'
gem 'haml'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'leaflet-rails', '~> 1.2'
gem 'mail_form', '~> 1.5', '>= 1.5.1'
gem 'rack-cors', :require => 'rack/cors'
gem 'rails_sortable'
gem 'simple_form'
gem 'sitemap_generator'
gem 'tinymce-rails'
gem 'webpacker'
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap4'

ruby "2.6.6"
