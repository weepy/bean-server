require 'rubygems'
require 'sinatra'
require 'lib/expander'
require 'lib/source_file'
require 'settings'
require 'fileutils'

# get "/?*" do |c|
#   a = request.fullpath
#   file = a.slice(2, a.length)
#   
#   files = []
#   
#   Find.find(LoadPath) do |p|
#     files.push(p) if p.match(file)        
#   end
#   
#   html = "<h1>Files matching '#{file}'</h1>"
#   html += files.map { |f| "<p><a href='#{f}'>#{f}</a></p>"}.join
# end
# 

get %r{/=(.+)[?]?(.*)} do
  
  filenames = params[:captures][0]
  options = parse_params(request.fullpath.gsub(/^\/=/,"").split("?")[1])
  list = filenames.split(",").map do |s| 
            s=s.strip
            s+= ".js" unless s.match(/\./) 
            s
          end

  ex = Expander.new(list)
  ex.expand_list
  
  content_type(request.media_type || "text/plain")

  return ex.concatenated if  options[:concatenate] == "true"
      
  if ex.paths.length == 1
    send_file ex.full_paths[0]
  else
    this_host = request.url.split("/").slice(0,3).join("/")
    ex.paths.map do |file| 
      "document.write('<script type=\"text/javascript\" src=\"#{this_host}#{file}\"></script>');\n"
    end.join("")
  end
  
end

# handle anything else..
get "/*" do
 
  filename = request.fullpath.slice(1,request.fullpath.length-1)

  ret = []
  Find.find(LoadPath) do |path|
    if path.match(/#{filename}/) && !File.directory?(path) && !path.match(/\/\./)
      ret << path
    end
  end
  
  if ret.length == 0
    "couldn't find #{filename}"
  elsif ret.length == 1
    send_file ret[0]
  else
    this_host = request.url.split("/").slice(0,3).join("/")
    
    ret = ret.map do |r| 
      q = r.gsub(LoadPath,"")
      "<p><a href='#{this_host}#{q}'>#{q}</a></p>"
    end
    
    "<h1>Found #{ret.length} files matching '#{filename}'</h1>" + ret.join("")
  end
    
end

get "/*" do
  return "not impl"
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



