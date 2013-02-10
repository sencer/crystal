class Crystal
  def surface v, p, tol = 0
    Surface.new(surface_converter(v), real(p), tol)
  end
  private
  def conversion_matrix
    cos = -> x {Math.cos( x * Math::PI / 180 ).round(10)}
    sin = -> x {Math.sin( x * Math::PI / 180 ).round(10)}
    Matrix[
      [@a, @b * cos[@gamma], @c * cos[@beta]],
      [0, @b * sin[@gamma], @c * (cos[@alpha] - cos[@beta] * cos[@gamma]) / sin[@gamma]],
      [0, 0, @c * (1 - cos[@alpha] ** 2 - cos[@beta] ** 2 - cos[@gamma] ** 2 + 2 * cos[@gamma] * cos[@alpha] * cos[@beta])]
    ]
  end
  def surface_converter arr
    x = arr[0] == 0 ? Vector[1.0 / 0, 0, 0] : real([1.0 / arr[0], 0, 0])
    y = arr[1] == 0 ? Vector[0,1.0/0,0] : real([0, 1.0 / arr[1], 0])
    z = arr[2] == 0 ? Vector[0,0,1.0/0] : real([0, 0, 1.0 / arr[2]])
    hxy = get_h x, y
    get_h hxy, z
  end
  def get_h v1, v2
    m = [v1.magnitude, v2.magnitude, (v1-v2).magnitude]
    if m[0] == 1.0/0
      v2
    elsif m[1] == 1.0/0
      v1
    else
      s = m.reduce(:+)/2
      h = 2 * (s * m.map{|v| s - v}.reduce(:*)).sqrt / m[2]
      angle = (Math.acos(h/m[0]) * 180 / Math::PI).round(10)
      (v1/m[0]).rotate(v1.cross(v2), angle)*h
    end
  end
end
