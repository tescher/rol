# E-mail formatter
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i  # Use this if you don't want to allow multiple addresses with semicolons in between

# Site Name
SITE_TITLE = "Volunteer Management"
ORG_TITLE = "Habitat for Humanity Sauk-Columbia Area"
ORG_SHORT_TITLE = "HFHSCA"
ORG_SITE = "http://www.hfhsca.org"

# Our Time Zone
DEFAULT_TIME_ZONE = "Central Time (US & Canada)"

# Password length
MIN_PASSWORD_LENGTH = 6

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

# Link to old system if any
OLD_SYSTEM = "http://hfhsca.org/lead_access/login.php"
OLD_SYSTEM_NAME = "Old Lead Access"

# Pagination
NO_PAGINATION = true
WillPaginate.per_page = 15

# XML Schemas
PENDING_VOLUNTEERS_XSD = File.join(Rails.root, "db", "conversion_schemas", "pending_volunteers.xsd")