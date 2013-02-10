class CAtom
  attr_reader :atom
  def initialize arg
    if arg.is_a? Atom
      @atom = arg
    else
      @atom = Atom.new(arg)
    end
  end
  def pos= arg 
    @atom.pos = @atom.crystal.real(arg)
  end
  def pos 
    @atom.crystal.frac(@atom.pos)
  end
  def x() pos[0] end
  def y() pos[0] end
  def z() pos[0] end
  def x=(p) 
    @atom.pos = @atom.crystal.real([p,y,z])
  end
  def y=(p) 
    @atom.pos = @atom.crystal.real([x,p,z])
  end
  def z=(p) 
    @atom.pos = @atom.crystal.real([x,y,p])
  end
  def move!(v, n = 1)
    @atom.move! @atom.crystal.real(v), n
  end
  def move(v, n) 
    @atom.move @atom.crystal.real(v), n
  end
  private
  def method_missing *args
    @atom.send(*args)
  end
end
