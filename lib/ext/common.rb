module Upstatement
  module Common

    # Remove trailing and leading quote characters from a string.
    def chomp_quotes(value)
      value.gsub(/\A["']|["']\Z/, '') unless value.nil?
    end

    # Convert Hash to a DataStruct
    def h2o(obj)
      return case obj
      when Hash
        obj = obj.clone
        obj = obj.each_with_object({}) { |(k,v),o| o[k] = h2o(v) }
        OpenStruct.new(obj)
      when Array
        obj = obj.clone
        obj.map! { |i| h2o(i)  }
      else
        obj
      end
    end

  end # Common
end # Upstatement

# Expose recursive `h2o` as singleton method
Upstatement::Common.module_eval do
  module_function :h2o
  public          :h2o
end
