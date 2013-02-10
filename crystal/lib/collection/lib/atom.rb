class Collection
  def move! v, n=1
    @collection.each{|atom| atom.move! v, n}
    return self
  end
  def move v, n=1
    dup.move! v, n
  end
  def fixed= bool = true
    @collection.each{|atom| atom.fixed = bool}
  end
  def type= str
    @collection.each{|atom| atom.type = str}
  end
  def name= str
    @collection.each{|atom| atom.name = str}
  end
  def crystal= crystal
    @collection.each{|atom| atom.crystal = crystal}
  end
end
