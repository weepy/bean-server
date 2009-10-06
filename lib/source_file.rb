  class SourceFile
  
  attr_reader :filesystem_path
  
  def initialize filesystem_path
    @filesystem_path = filesystem_path
    raise "#{filesystem_path} does not exist" unless File.exists?(filesystem_path) 
  end

  def lines
     File.open(filesystem_path) { |f| f.readlines }
  end
  
  def path
    ret = @filesystem_path
    LoadPaths.each { |load_path| ret = ret.gsub(load_path, "") }
    ret
  end
  
  def dependencies
    ret = []
    lines.each do |line|
      line.strip!
      next if line.length == 0
      break if line.match(/^[^\/]/) || line.match(/^\/\/[^=]/)

      m  = line.match /^\/\/= require "(.+)"$/
      if m
        ret.push([m[1] + ".js", File.dirname(filesystem_path) ])
        next
      end
      
      m  = line.match /^\/\/= require <(.+)>$/
      ret.push( [m[1] + ".js"] ) if m
      
    end
    ret
  end
  
end