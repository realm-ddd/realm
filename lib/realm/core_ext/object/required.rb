class Object
  # http://stackoverflow.com/questions/13250447/can-i-have-required-named-parameters-in-ruby-2-x
  def required(arg)
    raise ArgumentError.new("Required keyword argument missing: #{arg.to_sym.inspect}")
  end

  alias_method :r, :required
end