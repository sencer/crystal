require_relative 'string'
require_relative 'object'
require_relative 'numeric'
class Array
  #exclusive elements
  def ^(other)
    (self - other) | (other - self)
  end
  #new array from two arrays. 
  def combine(other, op=nil)
    return [] if self.empty? || other.empty?
    clipped = self[0..other.length-1]
    zipped = clipped.zip(other)
    if op
      zipped.map { |a, b| a.send(op, b) }
    else
      zipped.map { |a, b| yield(a, b) }
    end
  end
  alias :old_x :*
  def *(x)
    if (x.is_a? Vector rescue false)
      (Matrix[self] * x)[0]
    else
      old_x x
    end
  end
  def to_v
    Vector[*self]
  end
  #TODO Rewrite/Rename these:
  def numbers!
    i = length - 1
    self.reverse_each do |elem|
      if elem.is_a? Array
        self[i] = elem.numbers!
      else
        elem.numeric? ? self[i] = Float(elem):self.delete_at(i)
      end
      i -= 1
    end
    return self
  end
  def numerify!
    self.each_index do |i|
      if self[i].is_a? Array
        self[i] = self[i].numerify!
      else
        self[i] = Float(self[i]) if self[i].numeric?
      end
    end
    return self
  end

end
