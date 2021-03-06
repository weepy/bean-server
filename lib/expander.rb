class Expander
  
  attr_reader :file_list
  
  def initialize list, extra_paths
    # 
    # @extra_paths = extra_paths
    
    # if extra_paths
    #       list = (extra_paths + list).flatten
    #     end
    
    @files = {}
    @file_finder = FileFinder.new extra_paths
    
    #raise @file_finder.all_paths.inspect

    @file_list = list.uniq.map { |l| load_file(l) }.map {|x| [x]}
    
  end
  


  def load_file(filename, relative = false)
    filesystem_path = false
    
    [".js",".coffee",""].each do |ext|
      f = "#{filename}#{ext}"

      filesystem_path = relative ? @file_finder.find_relative(f,relative) : @file_finder.find(f)
      break if filesystem_path
    end
    
    raise "Could not find #{filename} in load path (relative=#{!!relative})" if !filesystem_path
    add_source_file(filesystem_path)
    filesystem_path
  end
  
  def add_source_file path
    s = SourceFile.new(path)  
    @files[s.filesystem_path] = s
  end
  
  def expand_list
    while true
      newlist = expand_list_once
      break if newlist == @file_list
      @file_list = newlist
    end
  end
  
  def expand_list_once
    new_list = []
    
    @file_list.each do |file|
      this_file = @files[file[0]]
      
      #raise file[0] unless this_file
      begin; debugger; rescue; end
      
      dependencies = this_file.dependencies
      
      for_list = dependencies.map { |d| load_file(d[0], d[1]) }.map {|x| [x] }
  
      new_list += for_list
      new_list << file
      
    end
    new_list.uniq
  end
  
  def debugger2
  end
  
  def filesystem_paths
    file_list.map { |f| @files[f[0]].filesystem_path }
  end
  
  def paths
    file_list.map do |f| 
      @files[f[0]].path
    end
  end
  
  def concatenated
    file_list.map do |f| 
      @files[f[0]].source
    end.join(";\n") #semi colon is to guard closures looking like functions.
  end
  
end

