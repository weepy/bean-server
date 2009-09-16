Bean-Server
===

About
---


Server to serve javascript files and resolve dependencies.

Allows modular javascript to be tested and modularized in a similar form to ruby gems. This modularity allows for a much improved reusability.

Partly inspired by Sprockets, but more flexible.

Setup
----

To run:

<pre>ruby app.rb</pre>

Or add to passenger pane (config.ru supplied)

settings.rb provides 1 setting

LoadPath => the paths to load the Beans from

Use
----

From any local html page, or local server, you can call

<pre>&lt;script src='http://bean-server/=jquery,jquery.plugin,myvector,other_stuff'&gt;&lt;/script&gt;</pre>

The bean-server will then attempt to find these files in the repo and include them. It will also resolve internal dependencies.

Without the initial =, it will simply try and return the file in the path specified

<pre>&lt;script src='http://bean-server/jquery/jquery.js'&gt;&lt;/script&gt;</pre>


Script Dependencies
----

Script's can require other scripts using the following terminology (same syntax as Sprockets)

<pre>
//= require <file>
//= require "../lib/my_relative_file"
</pre>

These directives must be placed at the very top of the script. 

Concatenatation vs Pods
----

If there is more than one script to return as an include there are two options:

Default action is to returns a list of scripts in document.write form (a pod of scripts :-)

If the option "?concatenate=true" is passed in the search params, server will concatenate the scripts together