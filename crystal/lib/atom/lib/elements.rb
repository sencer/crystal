class Atom
  Elements = {
    :O => {
      :z => 8,
      :m => 15.999,
      :fname => "Oxygen",
      :name => :O,
      :pp => []
    },
    :Ti => {
      :z => 22,
      :m => 47.867,
      :fname => "Titanium",
      :name => :Ti,
      :pp => []
    },
    :X => {
      :z => 1,
      :m => 1,
      :fname => "Unspecified",
      :name => :X,
      :pp => []
    }
  }
  Elements.method_access = true
  Elements.each{ |_,v| v.method_access = true }
end
