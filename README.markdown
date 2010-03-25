# plex-web

This is intended to be an online extension of [Plex](http://www.plexapp.com/), the wonderful media center for Mac OS X.

## Running

What you need:

* Ruby 1.8 or Ruby 1.9
* [bundler](http://github.com/carlhuda/bundler)

How to start the app:

1. Check out this git repo:

        git clone git://github.com/eventualbuddha/plex-web.git

2. Re-lock the gem bundle for your version of Ruby and get the gems:

        bundle lock
        bundle install

3. Link your Plex database:

        ln -s ~/Library/Application\ Support/Plex/userdata/Database/MyVideos34.db db/development.sqlite3

4. Start the web site:

        bundle exec rails server