require_relative "atom"
# create a surface in the real space
class Surface
  # initialize the surface
  # - @param normal [Vector or Array] a vector normal to the surface
  # - @param point [Vector or Array] a point on the surface 
  def initialize normal, point
    self.normal = normal
    self.p = p
  end
  # get normal [Vector] surface normal vector
  attr_reader :normal
  # get p [Vector] a point on the surface
  attr_reader :p
  # set normal
  # - @param normal [Vector or Array] set the surface normal
  def normal= normal
    @normal = normal.to_v
  end
  # set p
  # - @param p [Vector or Array] set point p on the surface
  def p= p
    @point = p.to_v
  end
  # test if surface is above some point or Atom
  # - @param point [Atom or Array or Vector]
  # - @return [Numeric]
  def above? point
    dist(point) < 0
  end
  # test if surface is below some point or Atom
  # - @param point [Atom or Array or Vector]
  # - @return [Numeric]
  def below? point
    dist(point) > 0
  end
  # test if surface is above some point or Atom
  # - @param point [Atom or Array or Vector]
  # - @param tolerance [Numeric] [optional, default = 0] if point is closer to 
  # the surface than the tolerance, it will be assumed on the surface.
  # - @return [Numeric]
  def include? point, tolerance = 0
    dist(point).abs <= tolerance
  end
  # shortest distance of a point or of an Atom to the surface
  # - @param point [Atom or Array or Vector]
  # - @return [Numeric]
  def dist point
    point = point.pos(false) if point.is_a? Atom
    (point.to_v- @p).to_a * @normal / @normal.magnitude
  end
  # rotate the surface
  # - @param direction [Vector or Array]
  # - @param origin [Vector or Array] [optional, default = Vector[0, 0, 0]]
  # - @param angle [Numeric] angle in degrees
  # - @return self [Surface]
  def rotate! direction, origin = Vector[0, 0, 0], angle
    @normal = @normal.rotate!(direction.to_v, origin.to_v, angle)
    self
  end
  # move the Surface
  # - @param vector [Vector or Array]
  # - @return self [Surface]
  def move! vector
    @p += vector.to_v
    self
  end
end
