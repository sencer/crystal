require 'minitest/autorun'
require 'minitest/pride'
require_relative "../Collection.rb"

describe "Simple Cubic" do
  before do
    a = Atom.new :element => :Ti, :pos => [0,0,0]
    @coll = Collection.new
    @coll << a << a.move([0,0,1])
    @coll << @coll.move([0,1,0])
    @coll << @coll.move([1,1,0])
  end
  it "can be cloned and deep-cloned" do
    clone = @coll.clone
    deep_clone = @coll.dup
    assert clone.object_id != @coll.object_id
    assert clone[0].object_id == @coll[0].object_id
    assert deep_clone.object_id != @coll.object_id
    assert deep_clone[0].object_id != @coll[0].object_id
  end
  it "can be sorted in arbitrary directions" do

  end
end
