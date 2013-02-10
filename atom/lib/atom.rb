class Atom
  def x() @pos[0] end
  def y() @pos[1] end
  def z() @pos[2] end
  def x=(p) 
    @pos = Vector[p,y,z] 
  end
  def y=(p) 
    @pos = Vector[x,p,z] 
  end
  def z=(p) 
    @pos = Vector[x,y,p] 
  end
  def has_crystal?() !(@crystal.nil?) end
  def move! v, n = 1
    @pos += v.to_v * n
    self
  end
  def move v, n = 1
    ret = self.dup
    ret.move! v,n
  end
  def dist other
    pos = other.is_a?(Atom) ? other.pos : other.to_v
    has_crystal? ? crystal.dist(self, other):(@pos - pos).magnitude
  end
  def dup
    Atom.new(to_hash)
  end
  def to_hash
    { :type => @type.name.to_sym, :name => @name, :pos => @pos, :fixed => @fixed, :crystal => @crystal }
  end
  def to_s f = '%8.4f'
    ("%-6s" + "#{f} " * 3) % ([name] + pos.to_a) + (fixed.nil? ? "" : fixed.map{|v| v ? 0 : 1}.join(" "))
  end
  def inspect
    to_hash.to_s
  end
end
