class Collection
  def sort! *keys
    tol = []
    tol << keys.pop while keys[-1].is_a? Numeric
    @collection.sort! do |a,b|
      result = 0
      ks = keys.dup
      t = tol.dup
      while result == 0 and ks.length > 0
        key = ks.shift
        t.push @tol if t.length == 0
        case key
        when :type
          result = (a.type.name <=> b.type.name)
        when Symbol
          result = a.send(key)
          if result.is_a? Numeric
            result = result.approx_sort(b.send(key), t.pop)
          else
            result = result <=> b.send(key)
          end
        else
          result = (key.to_a * a.pos).approx_sort(key.to_a * b.pos, t.pop)
        end
      end
      result
    end
    return @collection
  end
  def sort *keys
    dup.sort! *keys
  end
end
