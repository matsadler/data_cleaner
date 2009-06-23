==Useage
  
  require 'rubygems'
  require 'data_cleaner'
  
  class TopSecret
    attr_accessor :name, :email, :reference, :secret, :date
    
    def initialize(name, email, reference, secret, date)
      @name = name
      @email = email
      @reference = reference
      @secret = secret
      @date = date
    end
    
    def valid?
      name.match(/^[a-z]+ [a-z]+$/i) &&
      reference.match(/^[a-z]{3}[0-9]{1,5}$/) &&
      date.is_a?(Time) || false
    end
    
  end
  
  module DataCleaner::Formats
    format "TopSecret" do |f|
      f.name [:first_name, " ", :last_name]
      f.email :email, &:name # passes the objects name to the email method
      f.reference Proc.new {|secret| "#{secret.name[0..2].downcase}#{secret.date.strftime("%y")}"}
      f.secret "test"
    end
  end
  
  secret = TopSecret.new("Matthew Sadler", "mat@foo.com", "mat09", "I like kittens", Time.now)
  puts secret.inspect
  puts "is valid? #{secret.valid?}"
  puts
  
  clean = DataCleaner::Cleaner.clean!(secret)
  
  puts clean.inspect
  puts "is valid? #{clean.valid?}"