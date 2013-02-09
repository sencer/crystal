require_relative "../../helper/lib/kernel"
class Collection
  def select! str = nil, &block
    @collection.select!{|v| v.evaluate(str)} unless str.nil?
    @collection.select!(&block) if block_given?
    self
  end
  def reject! str = nil, &block
    @collection.reject!{|v| v.evaluate(str)} unless str.nil?
    @collection.reject!(&block) if block_given?
    self
  end
  def select str = nil, &block
    dup.select! str, &block
  end
  def reject str = nil, &block
    dup.select! str, &block
  end
end
