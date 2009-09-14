Bean-Server
====

About
----


Simple server based on sinatra to serve javascript files and resolve dependencies.

This allows javascript to be tested and modularized in a similar form to ruby gems. This modularity allows for a much improved reusability.

Setup
---

To run:

<code>rupy app.rb</code>

Or add to passenger pane (config.ru supplied)

settings.rb provides 1 settings 

LoadPath => the paths to load the Beans from


Use
---

From any local html page, or local server, you can call

<script src='http://path_to_beanserver/=jquery.js,jquery.plugin.js,myvector.js,other_stuff.js'></script>

The bean-server will then attempt to find these files in the repo and include them. It will also resolve internal dependencies.

If the src is without the initial =, it will simply try and return the file in the path specified

<script src='http://path_to_beanserver/jquery/jquery.js'></script>

Script Dependencies
---

Script's can require other scripts using the following terminology (same syntax as Sprockets)

//= require <file>
//= require "../lib/my_relative_file"

These directives must be placed at the very top of the script.

Concatenate vs Bean Pods
---

If there is more than one script to return as an include there are two options:

1) bean-server will returns a list of scripts in document.write form
2) bean-server will concatenate the scripts together into a single contatenated script. 

1) is default. Pass in "?concatenate=true", to activate 2)