class Expander
  
  attr_reader :list
  
  def initialize file_list
    @list = file_list.uniq
    @files = {}
    xx = Time.now.to_f
    @i = 0 
    @all_paths = Dir["#{LoadPath}/**/*"]
    puts "Dir #{Time.now.to_f - xx}" 
    
    @list.each { |l| load_file(l, false) }

    
    
  end
  
  def load_file(filename, relative)
      xx = Time.now.to_f
    s = SourceFile.new(filename, relative, @all_paths)
    @i +=Time.now.to_f - xx
    @files[s.key] = s
  end
  
  def expand_list
   
   xx = Time.now.to_f
    while true
      newlist = expand_list_once
      break if newlist == @list
      @list = newlist
    end
    puts "XXx#{@i}"
    puts "   #{Time.now.to_f - xx}"
  end
  
  def expand_list_once
    new_list = []

    
    @list.each do |file|
          
      
      deps = @files[file].dependencies()
     
      
      deps.each do |d| 
        if d.match(/-RELATIVE$/)
          load_file(d.gsub(/-RELATIVE$/, ""), true)
        else
          load_file(d, false)
        end
      end
  
      new_list += deps
      new_list << file
      
    end
    
  
    new_list.uniq
    
  end
  
  def full_paths
    list.map { |f| @files[f].full_path }
  end
  
  def paths
    list.map {|f| @files[f].path}
  end
  
  def concatenated
    list.map {|f| @files[f].lines.join}.join(";\n")
  end
end