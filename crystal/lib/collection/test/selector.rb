require 'minitest/autorun'
require 'minitest/pride'
require_relative "../../helper/lib/array"

describe "Selector" do
  before "parser and yielder" do
    def parse arg
      conj = arg.scan(/and|or/).map{|v| v == 'and' ? :& : :|}
      args = arg.split /and|or/
      procs = []
      args.each do |arg|
        operator = arg.scan(/[>=<]{1,2}/)[0]
        arg = arg.split(operator).map{|v| v.numeric?? Float(v) : v} #.to_sym}
        procs.push Proc.new{|x| x.send(operator, arg[1])}
      end
      var = a
      return Pr
    end
    def calc *args
      yield *args
    end
  end
  it "parses (and/or)s" do
    c = "x < 10 and y > 10 or z > 1"
    assert calc(11,1,2, &parse(c))
  end
end
