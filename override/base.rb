class Override::Base
  def initialize method_name, block, klass
    @method_name = method_name
    @block = block
    @klass = klass
  end

  def execute
    @klass.send :define_method, @method_name, newdef
  end

  def newdef
    mod = Module.new
    old_result = @klass.new.send(@method_name)
    mod.define_singleton_method :__olddef__, -> { old_result }

    block = @block
    new_proc = Proc.new{ mod.instance_eval &block }
    new_proc

    # if @klass.method_defined? @method_name
    #   original_method = @klass.instance_method(@method_name)
    #   original_proc = proc do
    #     original_method.bind(self).call
    #   end
    # else
    #   original_proc = proc do
    #     nil
    #   end
    # end
    #
    # new_method = @block
    #
    # override_binding = proc{
    #   define_method :__olddef__, original_proc
    #   define_method :__newdef__, new_method
    # }
    #
    # Proc.new do
    #   (class << self; self; end).instance_eval &override_binding
    #   self.__newdef__
    # end
  end
end
