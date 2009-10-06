require 'rubygems'
require 'sinatra'
require 'lib/expander'
require 'lib/source_file'
require 'lib/file_finder'
require 'lib/filetree'
require 'settings'
require 'fileutils'


LoadPaths = Settings[:load_paths].map! {|p| File.expand_path(p)}.select {|p| File.directory? p }
CSS = "<style>body{font-family:arial,sans;background:#111;color:#ddd}a{color:#ddf}h1,h2,p{color:#f44}</style>\n"
get %r{/=(.+)[?]?(.*)} do
  start_time = Time.now.to_f
  
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
  if  options[:concat] == "true"
    ret = ex.concatenated
    return "// rendered by Beans in #{Time.now.to_f - start_time}s\n" + ret
  end
  
  
  if ex.paths.length == 1
    send_file ex.full_paths[0]
  else
    this_host = request.url.split("/").slice(0,3).join("/")
    ret = ex.paths.map do |file| 
      "document.write('<script type=\"text/javascript\" src=\"#{this_host}#{file}\"></script>');\n"
    end.join("")

    "// rendered by Beans in #{Time.now.to_f - start_time}s\n" + ret
  end
  
end

# handle anything else..
get "/*" do
  filename = request.fullpath.slice(1,request.fullpath.length-1)

  found = []
  LoadPaths.each do |load_path|
    Dir["#{load_path}/**/*"].each do |path|
      if !File.directory?(path) && path.match(/#{filename}/) && !path.match(/\/\./)
        found << {:path =>path, :load_path => load_path}
      end
    end
  end
  
  if found.length == 0
    CSS+"<p>couldn't find #{filename}</p>"
  else
    this_host = request.url.split("/").slice(0,3).join("/")
    
    files = found.map do |r| 
      q = r[:path].gsub(r[:load_path],"")
      "<p><a href='#{this_host}#{q}'>#{q}</a></p>"
    end
    
    CSS + "<h1>Found #{ret.length} files matching '#{filename}'</h1>" + files.join("")
  end
    
end

get "/*" do
  return "not impl"
  path = request.fullpath.gsub("^/","")
  
  LoadPaths.each do |load_path|
    full_path = "#{load_path}/#{path}"
    if File.exists? full_path
      send_file full_path
      content_type (request.media_type || "text/plain")
      return
    end
  end
  
  "// could not find file '#{path}' in load paths"
end

def parse_params u
  ret = {}
  (u || "").split("&").each do |x|
    t = x.split("=")
    ret[t[0].to_sym]=t[1]
  end
  ret
end