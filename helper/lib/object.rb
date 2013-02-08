class Object
  alias :old_display :display
  def display(new_line = true)
    m = new_line ? :puts : :print
    self.tap { |o| send(m, o) }
  end
  def it
    self
  end
  def numeric?
    false
  end
  def deep_clone
    return @deep_cloning_obj if @deep_cloning
    @deep_cloning_obj = clone
    @deep_cloning_obj.instance_variables.each do |var|
      val = @deep_cloning_obj.instance_variable_get(var)
      begin
        @deep_cloning = true
        val = val.deep_clone
      rescue TypeError
        next
      ensure
        @deep_cloning = false
      end
      @deep_cloning_obj.instance_variable_set(var, val)
    end
    deep_cloning_obj = @deep_cloning_obj
    @deep_cloning_obj = nil
    deep_cloning_obj
  end
  def to_sym
    self.to_s.to_sym
  end
end
