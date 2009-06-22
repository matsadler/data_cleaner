module DataCleaner
  class Format
    attr_accessor :klass, :attributes
    
    def initialize(klass)
      @klass = klass
      @attributes = []
    end
    
    def method_missing(name, *args, &block)
      args.push(block) if block
      attributes.push([name, args])
    end
    alias attribute method_missing
    
  end
end