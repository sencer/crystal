require 'minitest/autorun'
require 'minitest/pride'
require_relative "../surface.rb"

describe "Surface" do
  before do
    @surface = Surface.new [0,0,1], [1,1,1], 0.5
  end
  it "know up and down" do
    assert @surface.below? [-1,-3,5]
    assert @surface.above? [5,13,0]
  end
  it "tolerates deviations" do
    assert @surface.include? [2,5,0.5]
  end
  it "gives the distances" do
    @surface.dist([0,0,0]).must_equal -1
  end
end
