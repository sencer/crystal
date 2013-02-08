class String
  def paste str, j = ' ', align = :left
    if str.is_a? Array
      tmp = self.dup
      str.each do |s|
        tmp = tmp.paste s, j, align
      end
      tmp
    else
      slines = self.lines.map(&:chomp)
      s1lines = str.lines.map(&:chomp)
      (s1lines.count - slines.count).times{slines.push ""}
      l = slines.map(&:length).max
      l1 = s1lines.map(&:length).max
      case align
      when :left
        f  = "%-#{l}s"
        f1 = "%-#{l1}s"
      when :right
        f  = "%#{l}s"
        f1 = "%#{l1}s"
      else
        f  = '%s'
        f1 = '%s'
      end
      slines.map{|v| f % v}.zip(s1lines.map{|v| f1 % v}).map{|v| v.join(j)}.join("\n")
    end
  end
  def numeric?
    Float(self) != nil rescue false
  end
end
