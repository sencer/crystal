  # move all atoms in the selection
  # - @param args - check atom.move! for arguments
  # - @return self [Selection]
  def move *args
    @atoms.each{|atom| atom.move!(*args)}
    self
  end
  # rotate the selection through an axis
  # - @param direction [Vector or Array] direction of axis
  # - @param origin [Vector or Array], [optional, default = Vector[0,0,0]] 
  # - @param angle [Numeric] angle of rotation in degrees
  # - @return self [Selection]
  def rotate direction, origin = Vector[0,0,0], angle
    @atoms.each{|v| v.pos = v.pos.rotate(direction.to_v,origin.to_v,angle)}
    self
  end
  # mass assign type to all atoms in the selection
  # - @param type [String or Symbol]
  def type= type
    @atoms.each{|atom| atom.type = type}
  end
  # mass assign name to all atoms in the selection
  # - @param name [String or Symbol]
  def name= name
    @atoms.each{|atom| atom.name = name}
  end
  # mass assign cell to all atoms in the selection
  # - @param cell [Cell]
  def cell= cell
    @atoms.each{|atom| atom.crystal = crystal}
  end
  # mass assign units to all atoms in the selection
  # - @param units [String or Symbol]
  def units= units
    @atoms.each{|atom| atom.units = units}
  end
