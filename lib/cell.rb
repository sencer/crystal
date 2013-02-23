require_relative "atom"
require_relative "selection"
require_relative "surface"
# this class provides helper functions to convert between real space coordiantes
# and (fractional) crystal coordinates. once an instance created with crystal 
# parameters, its :frac and :real methods can be used to convert position 
# vectors, and :surface method to create a surface in real space, using crystal
# coordinates. 
class Cell < Selection
  attr_reader :a, :b, :c, :alpha, :beta, :gamma,:atoms
  # initialize with crystal parameters
  # - 1 parameter  : Cubic crystal, with side length param 
  # - 3 parameters : Orthorhombic crystal, with side lengths params
  # - 4 parameters : Monoclinic crystal with side lengths + beta params
  # - 6 parameters : Triclinic crystal
  def initialize *args
    @a = @b = @c = args[0].to_f
    @alpha = @beta = @gamma = 90.0
    if args.length > 2
      @b = args[1]
      @c = args[2]
    end
    case args.length
    when 4
      @beta = args[3]
    when 6
      @alpha = args[3]
      @beta = args[4]
      @gamma = args[5]
    end
    @abc2xyz = conversion_matrix 
    @xyz2abc = @abc2xyz.inv
    super()
  end
  # return fractional crystal coordinates for a vector in real space
  # - @param vector [Vector or Array]
  # - @return [Vector]
  def frac(vector) 
    @xyz2abc * vector.to_v 
  end
  # return real space coordinates for a vector in fractional coordinates 
  # - @param vector [Vector or Array]
  # - @return [Vector]
  def real(vector) 
    @abc2xyz * vector.to_v 
  end
  # return a Surface in real space for given Miller Indices and a point that
  # is on the surface
  # - @param miller [Vector or Array]
  # - @param pnt [Vector or Array], [optional, default = Vector[0.5, 0.5, 0.5]]
  def surface miller, pnt = Vector[0.5, 0.5, 0.5]
    Surface.new(surface_converter(miller), real(pnt))
  end
  # return shortest distance between to Vectors or Atoms considering periodic
  # boundary conditions. Receives fractional coordinates, returns real space 
  # distance always!
  # - @param first [Atom or Vector or Array]
  # - @param second [Atom or Vector or Array]
  # - @return [Float] distance
  def dist first, second
    first = first.is_a? Atom ? frac(first.pos(false)) : first.to_v
    second = second.is_a? Atom ? frac(second.pos(false)) : second.to_v
    real((first - second).map{|v| v = v % 1; v > 0.5 ? 1 - v : v}).magnitude
  end
  private
  def conversion_matrix
    cos = -> x {Math.cos( x * Math::PI / 180 ).round(10)}
    sin = -> x {Math.sin( x * Math::PI / 180 ).round(10)}
    Matrix[
      [@a, @b * cos[@gamma], @c * cos[@beta]],
      [0, @b * sin[@gamma], @c * (cos[@alpha] - cos[@beta] * cos[@gamma]) / 
       sin[@gamma]],
      [0, 0, @c * (1 - cos[@alpha] ** 2 - cos[@beta] ** 2 - cos[@gamma] ** 2 +
                   2 * cos[@gamma] * cos[@alpha] * cos[@beta])]
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
