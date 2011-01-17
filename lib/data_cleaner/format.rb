module DataCleaner
  class Format < if defined? BasicObject then BasicObject else Object end
    attr_accessor :klass, :attributes
    
    def initialize(klass)
      @klass = klass
      @attributes = []
    end
    
    def attribute(name, *args, &block)
      args.push(block) if block
      attributes.push([name, args])
    end
    alias method_missing attribute
    
  end
end