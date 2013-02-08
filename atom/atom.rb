require "matrix"
require_relative "../helper/lib/vector"
require_relative "../helper/lib/array"
require_relative "../helper/lib/hash"
require_relative "lib/atom"
require_relative "lib/elements"
class Atom
  attr_reader :pos, :cell, :type, :fixed
  def initialize params = {}
    @type = Elements[params[:type]] || Elements[:X]
    @name = (params[:name]||@type.name).to_sym
    @pos = (params[:pos].to_v rescue nil)
    @cell = params[:cell]
    @fixed = params[:fixed]
  end
  def type= (el)
    @type = Elements[el.to_sym]
    @name = @type.name
  end
  def name() @name.to_s end
  def name=(s)
    @name = s.to_sym
  end
  def pos=(v)
    @pos = v.to_v
  end
  def fixed=(*a)
    a.flatten!
    @fixed = a.length == 3 ? a : a * 3
  end
  def cell=(c)
    @cell = c if (c.is_a? Cell rescue false)
  end
  def evaluate str, b=nil
    str = str.gsub(/={1,2}/,"==").gsub(/(\[[^\]]*\])/,'\1.to_v')
    eval(str) ? true : false
  end
end
