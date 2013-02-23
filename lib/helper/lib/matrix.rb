require 'matrix'
class Matrix
  def to_s format='%.4f'
    return "" if empty?
    f = column_vectors.map(&->x{"%#{x.longest_string(format)}s"}).join(" ")
    map{|v| format % v}.row_vectors.map{|v| f % v.to_a}.join("\n")
  end
  def inspect format = '%.4f'
    return "Matrix[]" if empty?
    (["\nMatrix[ "] + ["        "]*(row_size-1)).zip(to_s.lines).map{|v| v.join}.join() + " ]"
  end
end
