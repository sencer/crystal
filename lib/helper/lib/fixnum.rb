class Fixnum
  def zero_pad total
    "%0#{total}d" % self
  end
  def length
    self.to_s.length
  end
end
