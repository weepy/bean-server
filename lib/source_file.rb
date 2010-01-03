class SourceFile
  
  attr_reader :filesystem_path
  attr_reader :extension

      
  def initialize filesystem_path
    @filesystem_path = filesystem_path
    raise "#{filesystem_path} does not exist" unless File.exists?(@filesystem_path)
  end
  
  def lines
    @lines ||= File.open(filesystem_path) { |f| f.readlines } 
  end
  
  def path
    ret = @filesystem_path
    LoadPaths.each { |load_path| ret = ret.gsub(load_path, "") }
    ret
  end
  
  def coffee?
    @filesystem_path.match(/\.coffee$/)
  end
  
  def source
    if coffee? 
      require "coffee-script"
      CoffeeScript.compile(lines.join("\n"))
    else
      lines.map {|l| l += l.match(/\n$/) ? "" : "\n" }.join
    end
  end
  
  REGEX_JS     = { :no_comment => /^[^\/]/, :comment_no_require => /^\/\/[^=]/, :relative_require => /^\/\/= require "(.+)"$/, :absolute_require => /^\/\/= require <(.+)>$/}
  REGEX_COFFEE = { :no_comment => /^[^#]/,  :comment_no_require => /^#[^=]/,    :relative_require => /^#= require "(.+)"$/,    :absolute_require => /^#= require <(.+)>$/}
  
  def dependencies
    ret = []
    regex = coffee? ? REGEX_COFFEE : REGEX_JS
    
    lines.each do |line|
      line.strip!
      next if line.length == 0
      break if line.match(regex[:no_comment]) || line.match(regex[:comment_no_require])

      m  = line.match regex[:relative_require]
      if m
        ret.push([m[1], File.dirname(filesystem_path) ])
        next
      end
      
      m  = line.match regex[:absolute_require]
      ret.push( [m[1]] ) if m
      
    end
    ret
  end
  
end