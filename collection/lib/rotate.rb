require 'matrix'
class Collection
  def rotate! v, o = Vector[0,0,0], a
    r = rotation_matrix v.to_v, o.to_v, a
    @collection.map!{|v| v.pos = Vector[*(r * Vector[*(v.pos),1]).to_a[0,3]]}
  end
  private
  def rotation_matrix d, ve, theta 
    m = d.magnitude
    u,v,w = d.to_a
    a,b,c = ve.to_a
    cos = Math.cos(theta / 180.0 * Math::PI)
    sin = Math.sin(theta / 180.0 * Math::PI)
    return Matrix.columns([
      [ u**2+cos*(v**2+w**2),
        u*v*(1-cos)+w*m*sin,
        u*w*(1-cos)-v*m*sin,
        0 ],
      [ v*u*(1-cos)-w*m*sin,
        v**2+cos*(u**2+w**2),
        v*w*(1-cos)-u*m*sin,
        0],
      [ u*w*(1-cos)+v*m*sin,
        w*v*(1-cos)-u*m*sin,
        w**2+cos*(v**2+u**2),
        0 ],
      [ (a*(v**2+w**2)-u*(b*v+c*w))*(1-cos)+(b*w-c*v)*m*sin,
        (b*(u**2+w**2)-v*(a*u+c*w))*(1-cos)+(c*u-a*w)*m*sin,
        (c*(u**2+v**2)-w*(a*u+b*v))*(1-cos)+(a*v-b*u)*m*sin,
        m**2 ]
    ])/(m**2)
  end
end
