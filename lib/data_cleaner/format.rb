module DataCleaner # :nodoc:
  # DataCleaner::Format can be used to describe the format of an object's
  # attributes.
  # 
  # Example:
  #   f = DataCleaner::Format.new("Person")
  #   f.name [:first_name, " ", :last_name]
  # 
  # You most likely do not want to use this class directly, but instead through
  # DataCleaner::Formats.
  # 
  class Format < if defined? BasicObject then BasicObject else Object end
    attr_accessor :klass, :attributes
    
    # :call-seq: Format.new(klass) -> format
    # 
    def initialize(klass)
      @klass = klass
      @attributes = []
    end
    
    # :call-seq: format.attribute(:attr [, args...]) {|obj| block } -> format
    # 
    def attribute(name, *args, &block)
      args.push(block) if block
      attributes.push([name, args])
      self
    end
    alias method_missing attribute
    
  end
end