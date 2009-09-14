require 'rubygems'
require 'sinatra'
require 'lib/expander'
require 'lib/source_file'
require 'settings'
require 'fileutils'


get %r{/=(.+\.js)[?]?(.*)} do
  
  filenames = params[:captures][0]
  options = parse_params(request.fullpath.gsub(/^\/=/,"").split("?")[1])
  list = filenames.split(",").map {|s| s.strip.gsub(/\.js$/,"") }

  ex = Expander.new(list)
  ex.expand_list
  
  content_type(request.media_type || "text/plain")

  return ex.concatenated if  options[:concatenate] == "true"
      
  if ex.paths.length == 1
    send_file ex.full_paths[0]
  else
    this_host =  request.url.split("/").slice(0,3).join("/")
    ex.paths.map do |file| 
      "document.write('<script type=\"text/javascript\" src=\"#{this_host}#{file}\"></script>');\n"
    end.join("")
  end
  
end

# handle anything else..
get "/=*" do
  "NOT YET"
end

get "/*" do
  name = request.fullpath.gsub("^/","")
  content_type (request.media_type || "text/plain")
  send_file "#{LoadPath}/#{name}"
end

def parse_params u
  ret = {}
  (u || "").split("&").each do |x|
    t = x.split("=")
    ret[t[0].to_sym]=t[1]
  end
  ret
end



