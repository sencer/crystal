class Numeric
  (Math.methods - Module.methods - ["hypot", "ldexp"]).each do |method|
    define_method method do
      Math.send method, self
    end
  end
  def approx_sort other, tol = self.to_f/1000
    d = self - other
    d > tol ? 1 : (-d > tol ? -1 : 0)
  end
  def numeric?
    true
  end
end
