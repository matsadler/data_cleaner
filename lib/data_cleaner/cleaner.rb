module DataCleaner
  # DataCleaner::Cleaner is a module which can either be mixed-in, or used
  # standalone to anonymise the data held within objects.
  # 
  # DataCleaner::Cleaner relies on the object formats specified with
  # DataCleaner::Formats.
  # 
  module Cleaner
    
    # :call-seq: Cleaner.clean_value(attr, klass, instance=nil) -> clean_value
    #
    # Returns a clean value accoring to the format for the attribute and class
    # specified. Be aware that if the format definition includes a block you
    # many need to supply an instance of the class or you may get errors.
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
        DataCleaner::Formats.helpers[first].call(*args)
      when Array
        first.map do |e|
          e = [e] unless e.is_a?(Array)
          __replacement__(e, object)
        end.join
      when Proc
        first.call(object)
      end
    end
    
  end
end