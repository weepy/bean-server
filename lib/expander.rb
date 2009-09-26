class Expander
  
  attr_reader :list
  
  def initialize file_list
    @list = file_list.uniq
    @files = {}
    @all_paths = Dir["#{LoadPath}/**/*"]
    @list.each { |l| load_file(l, false) }
    
    
    
  end
  
  def load_file(filename, relative)
    s = SourceFile.new(filename, relative, @all_paths)
    @files[s.key] = s
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
      s = Time.now.to_f
      deps = @files[file].dependencies()
      puts "Deps for #{file} took #{Time.now.to_f - s}s"
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