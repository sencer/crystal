require_relative "../atom/atom"
require_relative "../helper/lib/numeric"

require_relative "lib/enum"
require_relative "lib/selector"
require_relative "lib/sort"
require_relative "lib/atom"
require_relative "lib/rotate"

class Collection
  def initialize *args
    @collection = []
    @tol = 0
    [*args].each{ |arg| self << arg }
  end
  def << arg
    if arg.is_a? Atom
      @collection << arg unless @collection.include? arg
      return self
    elsif arg.is_a? Collection
      @collection += arg.to_a
      @collection.uniq!
      return self
    elsif arg.is_a? Array
      @collection += arg if arg.all?{|v| v.is_a? Atom}
      @collection.uniq!
      return self
    end
    return false
  end
  def length() @collection.length end
  def pop n = 1
    @collection.pop n
  end
  def [] i, j = nil
    j.nil?? @collection[i] : @collection[i,j]
  end
  def []= index, atom
    if atom.is_a?(Atom) 
      @collection[index]=atom 
      @collection = @collection.uniq.compact
      true
    end
      false
  end
  def to_s
    String.new.tap{|s| @collection.each{|e| s << e.to_s << "\n"}}
  end
end
