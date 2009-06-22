Gem::Specification.new do |s|
  s.name = %q{data_cleaner}
  s.version = "0.0.1"
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Sadler"]
  s.date = %q{2009-06-22}
  s.description = %q{A Ruby library to aid in removing sensitive data from objects}
  s.email = %q{matthew.sadler@uk.clara.net}
  s.files = ["README.txt", "lib/data_cleaner.rb", "lib/data_cleaner/cleaner.rb", "lib/data_cleaner/format.rb", "lib/data_cleaner/formats.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://www.clara.net}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{A Ruby library to aid in removing sensitive data from objects}
  
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
    
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faker>, [">= 0.3.1"])
    else
      s.add_dependency(%q<faker>, [">= 0.3.1"])
    end
  else
    s.add_dependency(%q<faker>, [">= 0.3.1"])
  end
end