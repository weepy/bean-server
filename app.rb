require 'rubygems'
require 'sinatra'
require 'lib/expander'
require 'lib/source_file'
require 'settings'
require 'fileutils'

get "/=*" do
  url = request.fullpath.gsub(/^\/=/,"").split("?")
  filenames = url[0]
  options = url[1]
  
  list = filenames.split(",").map {|s| s.strip}

  ex = Expander.new(list)

  ex.expand_list
  content_type "text/js"
  #ex.paths.join(", ")
  if ex.paths.length == 1
    send_file ex.full_paths[0]
  else   
    ex.paths.map do |file| 
      "document.write('<script src=\"#{ServerUrl}/#{file}\"></script>');\n"
    end.join("")
  end

end


get "/*" do
  name = request.fullpath.gsub("^/","")
  path = find_load_path(name)
  #content_type request.media_type
  return "Could not find #{name} in load paths" unless path
  send_file "#{path}/#{name}"
end



def find_load_path f
  LoadPaths.each do |load_path|
    return load_path if File.exists? "#{load_path}/#{f}"
  end
  false
end


