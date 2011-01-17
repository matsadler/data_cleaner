Gem::Specification.new do |s|
  s.name = "data_cleaner"
  s.version = "0.0.1"
  s.summary = "A Ruby library to aid in removing sensitive data from objects"
  s.description = "A Ruby library to aid in removing sensitive data from objects"
  s.files = %W{lib}.map {|dir| Dir["#{dir}/**/*.rb"]}.flatten << "README.txt"
  s.require_path = "lib"
  s.rdoc_options << "--main" << "README.txt" << "--charset" << "utf-8"
  s.extra_rdoc_files = ["README.txt"]
  s.author = "Matthew Sadler"
  s.email = "mat@sourcetagsandcodes.com"
  s.homepage = "http://github.com/matsadler/data_cleaner"
  s.add_dependency("faker", "~> 0.3")
end