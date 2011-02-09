module DataCleaner
  # DataCleaner::Formats provides a DSL for describing, and method for looking
  # up the format of object's attributes, such that they can be replaced with
  # fake data, but still pass validation.
  # 
  # Not all attributes need be specified, only those that need be replaced.
  # 
  # Attributes will be processed in the order they are specified.
  # 
  # Example:
  #   module DataCleaner::Formats
  #     format "Person" do |f|
  #       f.name [:first_name, " ", :last_name]
  #       f.email :email, &:name # passes the name to the generate email method
  #       # custom format, block is provided with the instance
  #       f.reference do |instance|
  #         "#{instance.name[0..2].downcase}#{rand(89) + 10}"
  #       end
  #     end
  #   end
  # 
  module Formats
    class << self; attr_accessor :formats, :helpers end
    self.formats = {}
    self.helpers = {}
    
    # :call-seq: Formats.helper(name) {|*args| block } -> helper
    # 
    # Define a format helper, which can then be used in a format block
    # 
    # Example:
    #   module DataCleaner::Formats
    #     helper :ip_address do
    #       Array.new(4).map {rand(255)}.join(".")
    #     end
    #     
    #     format "Server" do |f|
    #       f.ip :ip_address
    #     end
    #   end
    # 
    def self.helper(name, &block)
      helpers[name] = block
    end
    
    # :call-seq: Formats.format(klass) {|format| block } -> format
    # 
    # Yields a format object, which can be used to describe the format of klass.
    # 
    def self.format(klass)
      obj = Format.new(klass)
      yield obj
      formats[klass.to_s] = obj
    end
    
    # :call-seq: Formats.attribute_format(klass, attribute) -> attribute_format
    # 
    # Returns the format for a particular attribute as described in a format
    # block.
    # 
    def self.attribute_format(klass, attribute)
      format = formats[klass.to_s]
      if format
        attribute, attribute_format = format.attributes.assoc(attribute.to_sym)
        attribute_format
      end
    end
    
    # Set up default helpers
    # 
    # In the format
    #   :name => reciever
    # the method name will be called on reciever
    # 
    # whereas with
    #   :name => [reciever, :method]
    # the method method will be called on reciever.
    # 
    # :name is used when describing the format of your object's attributes
    # 
    {
      :name => Faker::Name,
      :first_name => Faker::Name,
      :last_name => Faker::Name,
      :name_prefix => [Faker::Name, :prefix],
      :name_suffix => [Faker::Name, :suffix],
      
      :phone_number => Faker::PhoneNumber,
      
      :city => Faker::Address,
      :city_prefix => Faker::Address,
      :city_suffix => Faker::Address,
      :secondary_address => Faker::Address,
      :street_address => Faker::Address,
      :street_name => Faker::Address,
      :street_suffix => Faker::Address,
      :uk_country => Faker::Address,
      :uk_county => Faker::Address,
      :uk_postcode => Faker::Address,
      :us_state => Faker::Address,
      :us_state_abbr => Faker::Address,
      :zip_code => Faker::Address,
      
      :domain_name => Faker::Internet,
      :domain_suffix => Faker::Internet,
      :domain_word => Faker::Internet,
      :email => Faker::Internet,
      :free_email => Faker::Internet,
      :user_name => Faker::Internet,
      
      :bs => Faker::Company,
      :catch_phrase => Faker::Company,
      :company_name => [Faker::Company, :name],
      :company_suffix => [Faker::Company, :suffix],
      
      :paragraph => Faker::Lorem,
      :paragraphs => Faker::Lorem,
      :sentence => Faker::Lorem,
      :sentences => Faker::Lorem,
      :words => Faker::Lorem,
    }.each do |name, (reciever, method)|
      helper(name, &reciever.method(method || name))
    end
    
  end
end