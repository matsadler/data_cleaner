unless :Symbol.respond_to?(:to_proc)
  class Symbol
    def to_proc
      Proc.new(&method(:__apply__))
    end
    
    private
    def __apply__(*args)
      args.shift.send(self, *args)
    end
  end
end

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
    class << self; attr_accessor :formats end
    self.formats = {}
    
    # :call-seq: format(klass) {|format| block } -> format
    # 
    # Yields a format object, which can be used to describe the format of klass.
    # 
    def self.format(klass)
      obj = Format.new(klass)
      yield obj
      formats[klass.to_s] = obj
    end
    
  end
end