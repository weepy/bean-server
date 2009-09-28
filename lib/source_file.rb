require 'find'

class SourceFile
  
  attr_reader :filename, :full_path, :lines
  
  def initialize filename, relative, all_paths
    @filename = filename
    @relative = relative
           
    if relative
      @full_path = LoadPath + @filename
      @path = @filename
    else
      unless find_file(filename, all_paths)
        raise "Could not find #{filename} in load path" 
      end
    end
  end
  
  def key
    filename + (@relative ? "-RELATIVE" : "") 
  end
  
  def lines
     File.open(full_path) { |f| f.readlines }
  end
  
  def dependencies
    ret = []
    lines.each do |line|
      line.strip!
      next if line.length == 0
      break if line.strip.match /^\/\/[^=]/

      m  = line.match /^\/\/= require "(.+)"$/
      if m
        ret.push(folder + m[1] + ".js" + "-RELATIVE")
        next
      end
      
      m  = line.match /^\/\/= require <(.+)>$/
      ret.push( m[1] + ".js" ) if m
      
    end
    ret
  end

  def folder
    path.split("/").slice(0..-2).join("/") +"/"
  end
  
  def path
    @path 
  end
  
  def find_file f, all_paths
    
    all_paths.each do |path| 
      
      if path.match(/\/#{f}$/) && !File.directory?(path)  
        
        @full_path = path
        @path = @full_path.gsub(LoadPath, "")
        return true
      end
    end

    
    false
  end
  
end