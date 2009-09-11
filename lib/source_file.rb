require 'find'

class SourceFile
  
  attr_reader :filename, :path
  
  def initialize f
    @filename = f
  end
  
  def lines
    File.open(full_path) { |f| f.readlines }
  end
  
  def dependencies
    ret = []
    lines.each do |line|
      line.strip!
      next if line.length == 0
      m  = line.match /^\/\/= require <(.+)>/
      ret.push(m[1]) if m
      break if line.strip.match /^\/\/[^=]/
    end
    ret
  end

  def full_path
    find_file unless @full_path
    raise "Could not find #{@filename} in load paths" unless @full_path
    @full_path
  end
  
  def find_file
    LoadPaths.each do |lp|
      Find.find(lp) do |p|
        puts p
        if p.match(/\/#{@filename}$/)
          @load_path = lp 
          @path = p.gsub(lp, "")
          @full_path = p
          return true
        end
      end
    end
    false
  end
end