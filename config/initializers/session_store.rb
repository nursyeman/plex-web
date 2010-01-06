# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gotdns_session',
  :secret      => 'e1411c2ff7af11d73bab07e65a9a80363ab699c7c885828393c6988846e755d00c9897939416419ad5029c47551c62f7166347f4962d543e8ea15b9706efc8e3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
