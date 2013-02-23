module Kernel
  def fn(*funs)
    -> x do
      funs.inject(x) do |v,f|
        Proc === f ? f.call(v) : v.send(f)
      end
    end
  end
  def prompt(text='', conversion=nil)
    print text unless text.empty?
    input = gets.chomp
    CONVERSIONS.include?(conversion) ? input.send(conversion) : input
  end
  def with(object,&block)
    object.instance_eval(&block)
  end
  # def with(o, &blk)
  #   o.tap(&blk)
  # end
end
