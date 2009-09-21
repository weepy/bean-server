require 'find'

class SourceFile
  
  attr_reader :filename, :full_path, :lines
  
  def initialize filename
    @filename = filename
    
    if filename.match(/\.js$/)
      @relative = true
      @full_path = LoadPath + @filename
      @path = @filename
    else
      @filename += ".js" unless @filename.match(/\./)
      unless find_file
        raise "Could not find #{filename} in load path" 
      end
    end
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
        ret.push(folder + m[1] + ".js")
        next
      end
      
      m  = line.match /^\/\/= require <(.+)>$/
      ret.push(m[1]) if m
      
    end
    ret
  end

  def folder
    path.split("/").slice(0..-2).join("/") +"/"
  end
  
  def path
    @path 
  end
  
  def find_file
       
    Find.find(LoadPath) do |path| 
      
      if path.match(/\/#{@filename}$/) && !File.directory?(path)  
        
        @full_path = path
        @path = @full_path.gsub(LoadPath, "")
        return true
      end
    end

    
    false
  end
  
end