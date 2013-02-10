require_relative 'lib/helper/all'
require_relative 'lib/collection/collection'
require_relative 'lib/surface/surface'

require_relative 'lib/crystal/catom'
require_relative 'lib/crystal/surface'

class Crystal
  #TODO define select/reject etc for crystal module.
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
  def frac(v) @xyz2abc * v.to_v end
  def real(v) @abc2xyz * v.to_v end
  def [] i, j = nil
    j.nil?? @crystal[i] : @crystal[i,j]
  end
  def []= i, v
    @crystal[i] = CAtom.new(arg) if v.is_a? Atom
  end
  def to_s
    String.new.tap{|s| @crystal.each{|e| s << e.to_s << "\n"}}
  end
  private
  def method_missing *args, &block
    @atoms.send(*args, &block)
  end
end
