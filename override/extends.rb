class Module
  def override_method method_name, &block
    Override::Base.new(method_name, block, self).execute
  end
end
