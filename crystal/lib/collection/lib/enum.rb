class Collection
  # include Enumerable
  def each
    if block_given?
      @collection.each { |e| yield(e) }
    else
      Enumerator.new(self, :each)
    end
  end 
  def map!
      @collection.map!{|c| yield(c); c}
  end
  def map &block
    dup.map!(&block)
  end
  def clone
    Collection.new.tap{|t| t << @collection }
  end
  def dup
    Collection.new.tap do |t|
      @collection.each do |e|
        t << e.dup
      end
    end
  end
  def to_a 
    @collection
  end
  def remove arg 
    arg.is_a?(Atom)? @collection.delete(arg): @collection.delete_at(arg)
  end
  alias :delete :remove
end
