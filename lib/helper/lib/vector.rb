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
  def rotate direction, origin = Vector[0,0,0], angle
    Vector[*(rotation_matrix(direction, origin, angle) * Vector[*(self),1]).to_a[0,3]]
  end
  def cross v2
    raise ArgumentError, "Vectors should be 3D" if self.size != 3 or v2.size != 3
    Vector[
      self[1]*v2[2] - self[2]*v2[1],
      self[2]*v2[0] - self[0]*v2[2],
      self[0]*v2[1] - self[1]*v2[0]
    ]
  end
  private
  def rotation_matrix direction, origin, theta 
    u,v,w = direction.normalize.to_a
    a,b,c = origin.to_a
    cos = Math.cos(theta / 180.0 * Math::PI).round(10)
    sin = Math.sin(theta / 180.0 * Math::PI).round(10)
    return Matrix.columns([
      [ u**2+cos*(v**2+w**2),
        u*v*(1-cos)+w*sin,
        u*w*(1-cos)-v*sin,
        0 ],
        [ v*u*(1-cos)-w*sin,
          v**2+cos*(u**2+w**2),
          v*w*(1-cos)+u*sin,
          0],
          [ u*w*(1-cos)+v*sin,
            w*v*(1-cos)-u*sin,
            w**2+cos*(v**2+u**2),
            0 ],
            [ (a*(v**2+w**2)-u*(b*v+c*w))*(1-cos)+(b*w-c*v)*sin,
              (b*(u**2+w**2)-v*(a*u+c*w))*(1-cos)+(c*u-a*w)*sin,
              (c*(u**2+v**2)-w*(a*u+b*v))*(1-cos)+(a*v-b*u)*sin,
              1 ]
    ])
  end

end
