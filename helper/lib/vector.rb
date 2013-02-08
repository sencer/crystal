class Vector
  def to_s format = '%.4f'
      return "" if size == 0
      w = longest_string format
      map{|v| "%#{w}s" % (format % v)}.to_a.join("\n")
  end
  def inspect format = '%.4f'
    return "Vector[]" if size == 0
    (["\nVector[ "] + ["        "]*(size-1)).zip(to_s.lines).map{|v| v.join}.join() +" ]"
  end
  def longest_string format
    map{|x| (format % x).length}.max
  end
  def to_v
    self
  end
end
