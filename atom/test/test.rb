require 'minitest/autorun'
require 'minitest/pride'
require_relative "../atom.rb"

describe "Atom" do
  before do
    @atom = Atom.new :element => :Os, :pos => [0,0,0]
    @atom2 = Atom.new :pos => [0,3,4]
  end
  it "can be copied around" do
    @atom2 = @atom.move([2,3,4])
    @atom2.pos.must_equal(Vector[2,3,4])
    @atom.pos.must_equal(Vector[0,0,0])
  end
  it "and can be moved" do
    @atom.move!(Vector[1,0,0],2).pos.must_equal(Vector[2,0,0])
  end
  it "can calculate distances" do
    @atom.dist(@atom2).must_equal(5)
    @atom2.dist([2,3,4]).must_equal(2)
  end
end
