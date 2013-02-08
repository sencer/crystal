class Hash
  def extract(*ks)
    existing = keys & ks
    Hash[existing.zip(values_at(*existing))]
  end
  def has_shape?(shape)
    all? do |k, v|
      Hash === v ? v.has_shape?(shape[k]) : shape[k] === v
    end
  end
  attr_accessor :method_access
  alias :old_m :method_missing
  def method_missing(m)
    if (@method_access.nil? ? (@@method_access rescue false) : @method_access)
      if has_key? m
        return self[m]
      elsif has_key? m.to_s
        return self[m.to_s]
      end
    end
    return old_m(m)
  end
  class << self
    def method_access=(bool) @@method_access = bool end
    def method_access() @@method_access end
  end
end
