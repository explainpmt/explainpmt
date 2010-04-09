# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_new_explainpmt_session',
  :secret      => '809738e9a31cd4cfd966873c932d484be1de543b65cde4a54ab0b5f9e0ad92c952578692f165e20b5f6d6e7354473e824bcf9cbcbbfaaaf9c954c2f02a92a4a2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
