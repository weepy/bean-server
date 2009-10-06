class FileFinder  
  def initialize 
    @all_paths = LoadPaths.map { |path| Dir["#{path}/**/*"] }
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