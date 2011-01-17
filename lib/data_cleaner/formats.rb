unless :Symbol.respond_to?(:to_proc)
  class Symbol
    def to_proc
      Proc.new(&method(:__apply__))
    end
    
    private
    def __apply__(obj, *args)
      obj.send(self, *args)
    end
  end
end

module DataCleaner
  module Formats
    class << self; attr_accessor :formats end
    
    @formats = {}
    
    def self.format(klass)
      obj = Format.new(klass)
      yield obj
      formats[klass.to_s] = obj
      obj
    end
    
  end
end