class Expander
  
  attr_reader :list
  
  def initialize file_list
    @list = file_list.uniq
    @files = {}
    @file_finder = FileFinder.new
    @list.each { |l| load_file(l) } 
  end
  
  def load_file(filename, relative = false)
    s = SourceFile.new(filename, relative, @file_finder)
    @files[s.full_path] = s
  end
  
  def expand_list
    while true
      newlist = expand_list_once
      break if newlist == @list
      @list = newlist
    end
  end
  
  def expand_list_once
    new_list = []
    
    @list.each do |file|
      deps = @files[file].dependencies
      
      deps.each do |d| 
        load_file(d[0], d[1])
      end
  
      new_list += deps
      new_list << [file]
      
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

