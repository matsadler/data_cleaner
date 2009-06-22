class Symbol
  def to_proc
    Proc.new do |obj|
      obj.send(self)
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