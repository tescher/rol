# E-mail formatter
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i  # Use this if you don't want to allow multiple addresses with semicolons in between

# Our Time Zone
DEFAULT_TIME_ZONE = "Central Time (US & Canada)"

#Fedex Address Checker
FEDEX_KEY =  ENV["RAILS_FEDEX_KEY"]
FEDEX_PASSWORD = ENV["RAILS_FEDEX_PASSWORD"]
FEDEX_ACCOUNT = ENV["RAILS_FEDEX_ACCOUNT"]
FEDEX_METER = ENV["RAILS_FEDEX_METER"]
FEDEX_MODE = ENV["RAILS_FEDEX_MODE"]

#Google reCAPTCHA keys
GOOGLE_SITE_KEY = ENV["RAILS_GOOGLE_SITE_KEY"]
GOOGLE_SECRET_KEY = ENV["RAILS_GOOGLE_SECRET_KEY"]

# Locked organization types
LOCKED_ORGANIZATION_TYPES = [1]

# Pagination
# WillPaginate.per_page = Utilities::Utilities.system_setting(:records_per_page)