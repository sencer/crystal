require_relative "atom"
# create a collection of atoms. can only include atoms, and no duplicate entries
# allowed 
class Selection
  # initialize new Selection
  # - @param *args [Atom, Array(of Atoms) or Selection]
  def initialize *args
    @atoms = []
    @units = :angstrom
    [*args].each{ |arg| self << arg }
  end
  # add atoms to selection 
  # - @param arg [Atom or Array or Selection]
  # - @raise [ArgumentError] if trying to add non-atoms
  def << arg
    case arg
    when Atom
      @atoms << arg unless @atoms.include? arg
    when Selection
      @atoms += arg.to_a
      @atoms.uniq!
    when Array
      arg.each{|atom| self << atom}
    else
      raise ArgumentError, "Only Atom instances are allowed!"
    end
    self
  end
  # number of atoms in the selection
  # - @return [Fixnum]
  def size
    @atoms.length 
  end
  # remove the last n atoms from selection and return it
  # - @param n [Fixnum], [optional, default = 1]
  # - @return [Atom]
  def pop n = 1
    @atoms.pop n
  end
  # remove the first n atoms from selection and return it
  # - @param n [Fixnum], [optional, default = 1]
  # - @return [Atom]
  def shift n = 1
    @atoms.shift n
  end
  # get a new selection of j atoms, from i-th index of self
  # - @param i [Fixnum]
  # - @param j [Fixnum], [optional, default = 1]
  def [] i, j = 1
    Selection.new.tap{|t| t << @atoms[i,j]}
  end
  # set i-th atom. If i is larger than size + 1, then atom will be appended
  # - @param i [Fixnum]
  # - @param atom [Atom]
  # - @return [Boolean]
  def []= i, atom
    if atom.is_a?(Atom) 
      @atoms[i]=atom 
      @atoms = @atoms.uniq.compact
      true
    end
      false
  end
  # return string representation of selection
  def to_s
    String.new.tap{|s| @atoms.each{|e| s << e.to_s << "\n"}}
  end
  # iterate through all atoms in the selection if block given
  # return enumarator otherwise
  # - @return [Selection or Enumerator]
  def each
    if block_given?
      @atoms.each { |e| yield(e) }
      self
    else
      Enumerator.new(self, :each)
    end
  end 
  # map all atoms according the block given -can change properties of each atom 
  # in many ways
  # - @return self [Selection]
  def map!
      @atoms.map!{|c| yield(c); c}
      self
  end
  # duplicate the selection, and map atoms in the new one
  def map &block
    dup.map!(&block)
  end
  # create a new instance of Selection, with exact same atoms
  # - @return [Selection]
  def clone
    Selection.new.tap{|t| t << @atoms }
  end
  # create a new instance of Selection with duplicates of atoms [i.e. deep-copy]
  # - @return [Selection]
  def dup
    Selection.new.tap do |t|
      @atoms.each do |e|
        t << e.dup
      end
    end
  end
  # return atoms in the selection as an array
  # - @return Array
  def to_a 
    @atoms
  end
  # remove an atom from the selection, either by providing it as an argument
  # or its index
  # - @param arg [Atom or Fixnum]
  # - @return self [Selection]
  def remove arg 
    arg.is_a?(Atom)? @atoms.delete(arg): @atoms.delete_at(arg)
    self
  end
  alias :delete :remove
  # restrict selection to a subset of the current one by providing either an 
  # argument that evaluates to boolean and/or a block. argument prevails!
  # - @param test [String] any string that will evaluate to boolean for an Atom 
  # instance like "x < y and name =~ /Ti/"
  # - @return self [Selection]
  def select! test = nil, &block
    @atoms.select!{|v| v.check(test)} unless test.nil?
    @atoms.select!(&block) if block_given?
    self
  end
  # restrict selection to a subset of the current one by rejection a part of it 
  # providing either an argument that evaluates to boolean and/or a block. 
  # argument prevails!
  # - @param test [String] any string that will evaluate to boolean for an Atom 
  # instance like "x < y and name =~ /Ti/"
  # - @return self [Selection]
  def reject! test = nil, &block
    @atoms.reject!{|v| v.check(test)} unless test.nil?
    @atoms.reject!(&block) if block_given?
    self
  end
  # duplicate the selection, then restrict it using select! non-destructive
  # - @param test - see select!
  # - @return duplicate [Selection]
  def select test = nil, &block
    dup.select! test, &block
  end
  # duplicate the selection, then restrict it using reject! non-destructive
  # - @param test - see reject!
  # - @return duplicate [Selection]
  def reject test = nil, &block
    dup.select! test, &block
  end
  # sort the selection according arbitrary directions provided as Vectors or 
  # Arrays, after listing the directions one can list tolerances for each
  # direction.
  # - example:
  #     selection.sort!([0,0,1],[1,1,0],[1,-1,0],:type, 0.5,1)
  # this will sort the selection in z axis, if any two atoms are equivalent 
  # (+/- 0.5)than in [1,1,0] direction with larger tolerance (+/- 1), ties will 
  # be resolved in [1,-1,0] direction with no tolerance this time, and the last
  # tie-breaker is atom types.
  # - @return self [Selection]
  def sort *keys
    tol = []
    tol << keys.pop while keys[-1].is_a? Numeric
    @atoms.sort! do |a,b|
      result = 0
      ks = keys.dup
      t = tol.dup
      while result == 0 and ks.length > 0
        key = ks.shift
        t.push @tol if t.length == 0
        case key
        when :type
          result = (a.type.name <=> b.type.name)
        when Symbol
          result = a.send(key)
          if result.is_a? Numeric
            result = result.approx_sort(b.send(key), t.pop)
          else
            result = result <=> b.send(key)
          end
        else
          result = (key.to_a * a.pos).approx_sort(key.to_a * b.pos, t.pop)
        end
      end
      result
    end
    self
  end
  private
  def method_missing method, *arguments, &block
    if Atom.instance_methods.include?(method)
      if method.to_s.end_with? "="
        @atoms.each{|atom| atom.send(method, *arguments)}
      elsif arguments.length == 0
        @atoms.all?{|atom| atom.send(method) == @atoms[0].send(method)} ?
          @atoms[0].send(method) : "Inhomogenius set of atoms."
      else 
        @atoms.each{|atom| atom.send(method, *arguments, &block)}
        self
      end
    else
      super
    end
  end
end
