class FileFinder  
  attr_accessor :all_paths
  
  def initialize paths = []
    @all_paths = (paths + LoadPaths).map { |path| Dir["#{path}/**/*"] }    
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
  
  def find_relative path, relative
    file = File.expand_path("#{relative}/#{path}")
    File.exists?(file) ? file : nil
  end
  
end