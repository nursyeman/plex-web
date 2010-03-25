source :gemcutter

gem 'rails', '3.0.0.beta'

case RUBY_VERSION
when /1.9/
  gem 'sqlite3'
else
  gem 'sqlite3-ruby'
end

gem 'nokogiri'
gem 'rest-client'
gem 'haml'

gem 'rack-coffee'

group :test do
  gem "rspec-rails", ">= 2.0.0.beta.1"
end
