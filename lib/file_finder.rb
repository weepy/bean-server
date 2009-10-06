class FileFinder  
  def initialize 
    @all_paths = LoadPaths.map { |path| Dir["#{path}/**/*"] }
  end
  
  def find_file f
    @all_paths.each do |load_path|  
      load_path.each do |path|
        if path.match(/\/#{f}$/) && !File.directory?(path)  
          return [load_path, path] 
        end
      end
    end
    false
  end
  
end