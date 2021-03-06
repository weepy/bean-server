require 'rubygems'
require 'sinatra'
require 'lib/expander'
require 'lib/source_file'
require 'lib/file_finder'
require 'settings'
require 'fileutils'
require "g"

LoadPaths = Settings[:load_paths].map! {|p| File.expand_path(p)}.select {|p| File.directory? p }


get %r{/=(.+)[?]?(.*)} do
  start_time = Time.now.to_f
  
  filenames = params[:captures][0]
  options = parse_params(request.fullpath.gsub(/^\/=/,"").split("?")[1])

  list = filenames.split(",").map do |s| 
            s=s.strip 
            # s+= ".js" unless s.match(/\./)  # should probably remove this
            s
          end

  extra_paths = (options[:paths] || "").split(",")
  
  ex = Expander.new(list, extra_paths)
  ex.expand_list
   
  content_type(request.media_type || "text/plain")

  if options[:concat] == "true"
    return "// rendered by Beans in #{Time.now.to_f - start_time}s\n#{ex.concatenated}" 
  end

  if ex.file_list.length == 1
    send_file ex.filesystem_paths[0]
  else
    
    this_host = request.url.split("/").slice(0,3).join("/")
    scripts = ex.paths.map do |file|
      url = "#{this_host}#{file}"
      
      extra_paths.each do |p|
        if file.match p 
          file = file.gsub p, ""
          url = "#{this_host}#{file}?paths=" + p
        end
      end
      
      "document.write('<script type=\"text/javascript\" src=\"#{url}\"></script>');\n"
    end.join("")

    "// rendered by Beans in #{Time.now.to_f - start_time}s\n#{scripts}"
  end
  
end

# search
get "/*" do

  filename = request.fullpath.slice(1,request.fullpath.length-1)
  
  if filename[0] && filename[0] != "?"[0]
    return handle_serve_file filename
  end
  
  filename.gsub!("?","")

  filename.gsub!("*","")
  found = []
  LoadPaths.each do |load_path|
    Dir["#{load_path}/**/*"].each do |path|
      if !File.directory?(path) && path.match(filename) && !path.match(/\/\./)
        found << { :path =>path, :load_path => load_path }
      end
    end
  end

  # if found.length == 1
  #   send_file found[0][:path]
  #   return
  # end
  
  file_links = found.map do |r| 
    q = r[:path].gsub(r[:load_path],"")
    "<a href='#{q}'>#{q}</a>"
  end

  erb :file_list, :locals => {:file_links => file_links, :filename => filename == "" ? "*" : filename}
end




def handle_serve_file url
  
  filename = url.split("?")[0]
  options = parse_params(url.split("?")[1])
  
  paths = LoadPaths
  if options[:paths]
    paths = options[:paths].split(",") + paths
  end
  
  
  
  paths.each do |load_path|
    path = "#{load_path}/#{filename}"
    #raise path
    if File.exists? path  
      source = File.read(path)
      if path.match(/\.coffee$/)
        require "coffee-script"
        return CoffeeScript.compile source
      else
        return source
      end
    end
  end
  
  "// could not find #{filename}"
end




# get "/*" do
#   return "not impl"
#   path = request.fullpath.gsub("^/","")
#   
#   LoadPaths.each do |load_path|
#     full_path = "#{load_path}/#{path}"
#     if File.exists? full_path
#       send_file full_path
#       content_type (request.media_type || "text/plain")
#       return
#     end
#   end
#   
#   "// could not find file '#{path}' in load paths"
# end

def parse_params u
  ret = {}
  (u || "").split("&").each do |x|
    t = x.split("=")
    ret[t[0].to_sym]=t[1]
  end
  ret
end