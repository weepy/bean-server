require 'find'

class SourceFile
  
  attr_reader :filename, :full_path, :lines, :path
  
  def initialize filename, relative, file_finder
    @filename = filename
    @relative = relative
    @file_finder = file_finder
    
    if @relative
      @full_path = folder(relative) + @filename
      @path = @filename
    else
      file = file_finder.find_file(filename)
      raise "Could not find #{filename} in load path" if !file
      @path = file[0]
      @full_path = file[1] + @path 
    end
  end
  
  def key
    @full_path #[@filename, @relative_path] 
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
        ret.push([folder(path) + m[1] + ".js", @full_path])
        next
      end
      
      m  = line.match /^\/\/= require <(.+)>$/
      ret.push( [m[1] + ".js"] ) if m
      
    end
    ret
  end

  def folder(p)
    p.split("/").slice(0..-2).join("/") +"/"
  end
  
end