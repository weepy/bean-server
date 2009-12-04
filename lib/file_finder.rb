class FileFinder  
  attr_accessor :all_paths
  
  def initialize paths
    load_paths = LoadPaths
    if paths
      load_paths = (paths + load_paths)#.flatten
    end
    
    @all_paths = load_paths.map { |path| Dir["#{path}/**/*"] }
    
  end
  
  def find f
    @all_paths.each do |load_path|  
      
      load_path.each do |file|
        if file.match(/\/#{f}$/) && !File.directory?(file)  
          return file
        end
      end
    end
    false
  end
  
end