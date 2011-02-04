module DataCleaner
  # DataCleaner::Cleaner is a module which can either be mixed-in, or used
  # standalone to anonymise the data held within objects.
  # 
  # DataCleaner::Cleaner relies on the object formats specified with
  # DataCleaner::Formats.
  # 
  module Cleaner
    # In the format 
    #   :specifier => instance
    # the method specifier will be called on instance
    # 
    # whereas with
    #   :specifier => [instance, :method]
    # the method method will be called on instance.
    # 
    # :specifier is used when describing the format of your object's attributes
    # 
    MAPPING = {
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
    }
    
    # :call-seq  return_clean_attribute(class_name,:field) =>  clean_value
    #
    # return a cleaned value for a particular class's attribute
    # 
    def self.clean_value(attribute, klass=self, object=nil)
      arguments = DataCleaner::Formats.attribute_format(klass, attribute)
      __replacement__(arguments, object)
    end
    
    extend self
    
    # :call-seq: Cleaner.clean(obj) -> new_obj
    # obj.clean -> new_obj
    # 
    # Returns an anonymised copy of obj.
    # 
    # Relies on obj.dup.
    # 
    def __clean__(object=self)
      __clean__!(object.dup)
    end
    unless defined? clean
      alias clean __clean__
    end
    
    # :call-seq: Cleaner.clean!(obj) -> obj
    # obj.clean! -> obj
    # 
    # Anonymises obj.
    # 
    def __clean__!(object=self)
      format = DataCleaner::Formats.formats[object.class.name]
      
      format.attributes.each do |attribute, arguments|
        object.send(:"#{attribute}=", __replacement__(arguments, object))
      end
      object
    end
    unless defined? clean!
      alias clean! __clean__!
    end
    
    private
    def __replacement__(args, object)
      args = args.dup
      first = args.shift
      
      case first
      when String
        first
      when Symbol
        args.map! {|arg| if arg.is_a?(Proc) then arg.call(object) end || arg}
        __data__(first, *args)
      when Array
        first.map do |e|
          e = [e] unless e.is_a?(Array)
          __replacement__(e, object)
        end.join
      when Proc
        first.call(object)
      end
    end
    
    def __data__(type, *args)
      klass, method = DataCleaner::Cleaner::MAPPING[type]
      klass.send(method || type, *args)
    end
    
  end
end