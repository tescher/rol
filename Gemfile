source 'http://rubygems.org'

ruby "2.6.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.5'
# Crypto for password hashing
gem 'bcrypt', '3.1.7'

# Used in Rails 5.2+
gem 'bootsnap'

# DB Seeder
gem 'faker'

# Paginater
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Multiselect helper
gem 'bootstrap-multiselect-rails'

# Fedex address checker
gem 'fedex', :github => 'tescher/fedex', :branch => 'master'

# Datepicker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.0'

# Date validator
gem 'jc-validates_timeliness'

# Fix security issues
gem "json", ">= 2.3.0"
gem "rack", ">=2.2.3"
gem "websocket-extensions", ">= 0.1.5"



# Possessive noun helper
gem 'possessive'

# Easy Autocomplete
gem 'rails-jquery-autocomplete'

# Paranoid record deleter
gem "paranoia"

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# gem 'pg', "0.21.0"
gem 'pg'
# Use SCSS for stylesheets
gem 'sassc-rails'
gem 'bootstrap-sass'


# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.2.0'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
#gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '>= 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
#

group :test, :development do
  # Want to keep using assigns and assert-template in testing
  gem 'rails-controller-testing'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console

  gem 'byebug'

  gem 'listen'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # gem 'railroady'

  gem "timecop"
  #gem "guard"
  #gem "guard-minitest"
end

group :production do
  if ENV['HOSTING_VENDOR'] == "OpalStack"
    gem 'puma'
  end
  ###gem 'heroku-deflater'
  ###gem 'rails_12factor'
  ###gem 'unicorn',        '4.8.3'
end
