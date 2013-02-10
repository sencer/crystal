require 'matrix'
class Collection
  def rotate! d, o = Vector[0,0,0], a
    @collection.each{|v| v.pos = v.pos.rotate(d.to_v,o.to_v,a)}
    self
  end
  def rotate *args
    dup.rotate! *args
  end
end
