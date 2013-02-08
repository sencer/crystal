require 'matrix'
require_relative "../helper/lib/vector"
require_relative "../atom/atom"
class Surface
  attr_accessor :tol
  attr_reader :normal, :p
  def initialize v, p, tol = 0
    @normal = v.to_v || nil
    @p = p.to_v || Vector[0,0,0]
    @tol = tol
  end
  def normal=(a) @normal=a.to_v end
  def p=(a) @p=a.to_v end
  def above? p, tol = @tol
    dist(p) + tol < 0
  end
  def below? p, tol = @tol
    dist(p) - tol > 0
  end
  def include? p, tol = @tol
    dist(p).abs <= tol
  end
  def dist p
    p = p.pos if p.is_a? Atom
    (p.to_v- @p).to_a * @normal / @normal.magnitude
  end
end
