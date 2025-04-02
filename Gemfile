source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '3.1.0'

gem 'rails', '~> 6.1.7'
gem 'activesupport', '~> 6.1.7.3'
gem 'actionpack', '~> 6.1.7.3'
gem 'actionview', '~> 6.1.7.3'
gem 'activerecord', '~> 6.1.7.3'
gem 'concurrent-ruby', '1.3.4'

gem 'puma', '~> 5.6'
gem 'sassc-rails', '~> 2.1.2'

gem 'coffee-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.11'
gem 'pg', '~> 1.4'
gem 'dotenv-rails', '~> 2.8'
gem 'geocoder', '~> 1.8'
gem 'google-cloud-storage', '~> 1.44'
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
gem 'webpacker', '~> 5.4'
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap4'
gem 'bootstrap', '~> 5.3.3'
gem 'devise'
gem 'execjs'
gem 'flickraw', '~> 0.9.10'
gem 'friendly_id', '~> 5.4'
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 3.36'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console', '>= 4.2.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
