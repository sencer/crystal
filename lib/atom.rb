require "../lib/lib/helper/all"
require_relative "elements"
require_relative "surface"
require_relative "cell"
# create an Atom in the 3D space
class Atom
  # initialize an Atom instance
  # @param params [Hash]:
  # - :name  => any arbitrary name as string or symbol like Fe2
  # - :type  => Chemical Symbol of any Element as string or symbol.
  # - :pos   => coordinates of the atom as Vector or Array
  # - :units => :angstrom or :crystal (fractional) units
  # - :cell  => assign a crystal cell (initialized as Cell.new). This will 
  # set :units to :crystal and allow periodic boundry conditions for distance
  # 
  # All these attributes can be accessed, and modified after the initialization
  def initialize params = {}
    @units = :angstrom
    @type  = Elements[:X]
    @name  = @type.name
    @pos   = Vector[0,0,0]
    params.each do |k,v|
      self.send("#{k}=", v)
    end
  end
  # change atom type
  # - @param type [String or Symbol] Chemical symbol of an element (:Ti or "Ti")
  def type= type
    #TODO check this tmp thing
    tmp = @type
    @type = Elements[type.to_sym]
    @name = @type.name if (@name == tmp.name rescue false)
  end
  # change atom name 
  # - @param name [String or Symbol] an arbitrary name for atom (:Ti2 or "Ti2")
  def name= name
    @name = name.to_sym
  end
  # set position of the atom
  # - @param pos [Vector or Array] 3D position vector of the Atom instance 
  # in units @units
  # - @param allow_crystal [Boolean] [optional, default = true] set false if you
  # want to assign real space coordinates while @units = :crystal
  def pos= pos, crystal = true 
    @pos = (@units == :angstrom or !crystal)? pos.to_v : @cell.real(pos.to_v)
  end
  # set x coordinate of the atom (@pos[0])
  # - @param x [Numeric]
  # - @param allow_crystal [Boolean] [optional, default = true] set false if you
  # want to assign real space coordinates while @units = :crystal
  def x= x, crystal = true 
    @pos = (@units == :angstrom or !crystal)? Vector[x,y,z] : @cell.real(Vector[x,y,z])
  end
  # set y coordinate of the atom (@pos[1])
  # - @param y [Numeric]
  # - @param allow_crystal [Boolean] [optional, default = true] set false if you
  # want to assign real space coordinates while @units = :crystal
  def y= y, crystal = true 
    @pos = (@units == :angstrom or !crystal)? Vector[x,y,z] : @cell.real(Vector[x,y,z])
  end
  # set z coordinate of the atom (@pos[2])
  # - @param z [Numeric]
  # - @param allow_crystal [Boolean] [optional, default = true] set false if you
  # want to assign real space coordinates while @units = :crystal
  def z= z, crystal = true 
    @pos = (@units == :angstrom or !crystal)? Vector[x,y,p] : @cell.real(Vector[x,y,p])
  end
  # assign a crystal cell to the atom, or change it. an atom cannot be a part of
  # two different crystal cells at once!
  # - @param cell [Cell] 
  def cell=  cell
    @cell.delete self unless @cell.nil?
    case cell
    when Cell
      cell << self
      @cell = cell if cell.is_a? Cell 
      @units = :crystal
    when nil, false
      @cell = nil
    else
      raise ArgumentError, "Argument should be a Cell"
    end
  end
  # change the units,
  # - @param units [Symbol or String] :crystal or :angstrom
  def units= units
    units = units.downcase.to_sym
    case units
    when :crystal
      raise ArgumentError,
        "Can't switch to crystal units with self.cell = nil" if @cell.nil?
    when :angstrom
      @units = units
    else
      raise ArgumentError, "units should be :crystal or :angstrom"
    end
    @units = units
  end
  # attr_readers:
  # type of the Atom instace as Hash containing atomic number, full name etc.
  # - @return [Hash]
  attr_reader :type
  # name of the Atom instance
  # - @return [Symbol]
  attr_reader :name
  # units of the Atom instance
  # - @return [Symbol] :angstrom or :crystal
  attr_reader :units
  # crystal cell assigned to Atom instance or nil
  # - @return [Cell or NilClass]
  attr_reader :cell
  # position of the atom in units @units
  # - @param allow_crystal [Boolean] [optional, default = true] set false if 
  # @units = :crystal and you want to get real space coordinates vector
  # - @return [Vector] 
  def pos allow_crystal = true
    (@units == :angstrom or !allow_crystal)? @pos : @cell.frac(@pos)
  end
  # x-coordinate (@pos[0]) of the atom position in units @units
  # - @param allow_crystal [Boolean] [optional, default = true] set false if 
  # @units = :crystal and you want to get real space coordinates vector
  # - @return [Numeric] 
  def x allow_crystal = true
    (@units == :angstrom or !allow_crystal)? @pos[0] : @cell.frac(@pos)[0]
  end
  # y-coordinate (@pos[1]) of the atom position in units @units
  # - @param allow_crystal [Boolean] [optional, default = true] set false if 
  # @units = :crystal and you want to get real space coordinates vector
  # - @return [Numeric] 
  def y allow_crystal = true
    (@units == :angstrom or !allow_crystal)? @pos[1] : @cell.frac(@pos)[1]
  end
  # z-coordinate (@pos[1]) of the atom position in units @units
  # - @param allow_crystal [Boolean] [optional, default = true] set false if 
  # @units = :crystal and you want to get real space coordinates vector
  # - @return [Numeric] 
  def z allow_crystal = true
    (@units == :angstrom or !allow_crystal)? @pos[2] : @cell.frac(@pos)[2]
  end
  # move the atom by some vector
  # - @param vector [Vector or Array] the vector to move the atom by.
  # - @param n [Numeric] [optional, default = 1] multiply the vector with this
  # - @param allow_crystal [Boolean] [optional, default = true] set false if 
  # Atom instance is in crystal coordinates, but you want to move by real 
  # coordinates.
  # - @return [Atom] self
  def move vector, n = 1, allow_crystal = true
    @pos += (@units == :angstrom or !allow_crystal)? vector.to_v * n :
      @cell.real(vector.to_v * n)
    self
  end
  # rotate the atom(s position vector) through an axis
  # - @param direction [Vector or Array] direction of axis
  # - @param origin [Vector or Array], [optional, default = Vector[0,0,0]] 
  # - @param angle [Numeric] angle of rotation in degrees
  # - @return self [Selection]
  def rotate direction, origin = Vector[0,0,0], angle
    @pos.rotate!(direction.to_v,origin.to_v,angle)
  end
  # shortest distance of the atom to a point, to another atom, or to a surface 
  # If atom is a part of a crystal then periodic boundary conditions will apply. 
  # note that periodic boundary conditions won't apply to Surface case.
  # - @param other [Vector or Array or Atom or Surface]
  # - @param allow_periodic [Boolean] [optional, default = true] set false if 
  # you don't want periodic boundary conditions.
  # - @return [Numeric] distance
  def dist other
    case other
    when Atom
      pos = other.pos(false)
    when Surface
      return other.dist(self)
    else
      pos = pos.to_v 
    end
    if @units == :angstrom
      (@pos - pos).magnitude
    else
      @cell.dist(self, other)
    end
  end
  # check if Atom instance is below a Surface
  # - @param surface [Surface]
  # - @return [Boolean]
  def below? surface #TODO tolerance?
    raise ArgumentError, "Argument should be a surface" unless s.is_a? Surface
    surface.above? self
  end
  # check if Atom instance is on a Surface
  # - @param surface [Surface]
  # - @param tolerance [Numeric], [optional, default = 0]  
  # - @return [Boolean]
  def on? surface, tolerance = 0
    raise ArgumentError, "Argument should be a surface" unless s.is_a? Surface
    surface.include? self, tolerance
  end
  # check if Atom instance is above a Surface
  # - @param surface [Surface]
  # - @return [Boolean]
  def above? surface
    raise ArgumentError, "Argument should be a surface" unless s.is_a? Surface
    surface.below? self
  end
  # evaluates simple logic operations for the atom like "x < 1 and name = :Ti"
  # - @param test [String]
  # - @return [Boolean]
  def check test
    test = test.gsub(/={1,2}(?!~)/,"==").gsub(/(\[[^\]]*\])/,'\1.to_v')
    (eval(test) ? true : false) rescue false
  end
  # duplicate the atom
  # - @return [Atom]
  def dup
    Atom.new(to_hash)
  end
  # dump the atom to a hash that can be used to initialize a new atom directly
  # - @return [Hash]
  def to_hash
    {}.tap do |v|
      v[:type] = @type.name
      v[:name] = @name
      v[:pos] = @pos
      v[:cell] = @cell
      v[:units] = @units
    end
  end
  # create a string containing name and position 
  # - @param format [String] [optional, default = '%8.4f'] format string
  # - @return [String]
  def to_s format = '%8.4f'
    ("%-6s" + "#{format} " * 3) % ([name] + pos.to_a) 
  end
  # inspect
  def inspect
    "<Atom: #{to_s} [#{units}]>"
  end
end
