Bean-Server
====

This is a simple server based on sinatra to serve javascript files and resolve dependencies.

This allows javascript to be tested and modularized in a similar form to ruby gems. This modularity allows for a much improved reusability.

To run:

<code>rupy app.rb</code>

Or add to passenger pane (config.ru supplied)

Settings
----

settings.rb provides 2 settings 

:load_paths => the paths to load the Sprockets from

