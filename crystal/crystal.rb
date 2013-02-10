require 'matrix'
require_relative './lib/catom'
require_relative '../collection/collection'
require_relative '../surface/surface'
class Crystal
  attr_reader :a, :b, :c, :alpha, :beta, :gamma,:atoms
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
    @atoms = Collection.new
    @crystal = []
  end
  def << arg 
    case arg 
    when Atom
      arg.crystal = self
      @atoms << arg
      @crystal << CAtom.new(arg)
    when CAtom
      arg.crystal = self
      @atoms << arg.atom
      @crystal << arg
    when Collection
      arg.crystal = self
      @atoms = arg
      @crystal = [].tap{|t| @atoms.each{|a| t << CAtom.new(a)}}
    end
    return self
  end
  def length() @atoms.length end
  def frac(v) @xyz2abc * v.to_v end
  def real(v) @abc2xyz * v.to_v end
  def surface v, p, tol = 0
   Surface.new(surface_converter(v), real(p), tol)
  end
  def [] i, j = nil
    j.nil?? @crystal[i] : @crystal[i,j]
  end
  def []= i, v
    @crystal[i] = CAtom.new(arg) if v.is_a? Atom
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
