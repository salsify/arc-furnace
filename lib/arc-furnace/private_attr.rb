class Module

  private

  # Meta-programming to easily create private attribute reader methods.
  def private_attr_reader(*attrs)
    attr_reader(*attrs)
    private(*attrs)
  end

  # Meta-programming to easily create private attribute writer methods.
  def private_attr_writer(*attrs)
    attr_writer(*attrs)
    private(*attrs.map { |attr| "#{attr}=".to_sym })
  end

  # Meta-programming to easily create private attribute accessor methods.
  def private_attr_accessor(*attrs)
    private_attr_reader(*attrs)
    private_attr_writer(*attrs)
  end

  def private_alias_method(new_name, old_name)
    alias_method(new_name, old_name)
    private(new_name)
  end

end
