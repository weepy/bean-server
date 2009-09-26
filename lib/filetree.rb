require "pathname"

class FileTree

  def initialize roots, pattern
    @roots = roots.map {|r| Pathname(r).expand_path}
    @pattern = pattern
    @files = {}
    @ignore = /\/./ #git
    
    puts "hello"
    
    
  end
  
  attr_reader :files
  
  def update
    new_files = {}
    
    @roots.each do |root|
      Dir["#{root}/**/*"].each do |f|
        #next unless (!@pattern || f.match(@pattern)) && !f.match(@ignore)
        new_files[f] = 1  
      end
    end
    
    @files = new_files
  end
  
  def run
    puts "runningg ?!"
    loop do 
      start = Time.now.to_f
      update
      time = Time.now.to_f - start
      puts "Update took #{time}s"
      sleep(1)
    end
  end
end


=begin
MyFileTree = FileTree.new([LoadPath], /\.((js)|(css)|(png)|(gif)|(jpg)|(jpeg))$/)

Thread.new {
  MyFileTree.run
}
=end
