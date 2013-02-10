require './collection'

a = Collection.new Atom.new :pos => [0,0,0]
a << a.move([0,0,1]) << a.move([0,1,0]) << a.move([1,0,0])
puts a.rotate!([0,0,1], 90)
