class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages "Your login information is invalid"
end