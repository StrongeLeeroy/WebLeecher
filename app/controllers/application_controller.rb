class ApplicationController < ActionController::Base
  protect_from_forgery
include SessionsHelper
include SearchesHelper
filter_parameter_logging(:forumpass)
end
