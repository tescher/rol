ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'application_helper'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # set_fixture_class volunteer_category_volunteers: VolunteerCategoryVolunteer
  fixtures :all
  include ApplicationHelper

  ActiveRecord::FixtureSet.context_class.send :include, ApplicationHelper


  # Add more helper methods to be used by all tests here...
  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    post login_path, params: { session: { email:       user.email,
                                  password:    password,
                                  remember_me: remember_me } }
 end

  def logged_in_as(user)
    session[:user_id] = user.id
  end


  private

  # Returns true inside an integration test.
  def integration_test?
    defined?(post_via_redirect)
  end

end
