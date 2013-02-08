class File
  # repeat last ff/rew command
  def repeat
    if @find_registry[:method] == :ff
      seek(1,1)
      ff(@find_registry[:re])
    else
      rew(@find_registry[:re])
    end
  end
  # find all occurences of args (with or) 
  # in the file egardless of the current
  # position
  def findall *args
    p = pos
    seek(0)
    results = [ ff(*args).pos ]
    while !repeat.nil?
      results.push pos
    end
    seek(p)
    return results
  end
  # do not rewind, just give
  # the position that rew would 
  # rewind to.
  def rew? *args
    p = pos 
    p1 = rew(*args)
    p1.nil? ? p1 = nil : p1 = pos
    seek p
    return p1
  end
  # do not fast forward, just give
  # the position that ff would fast
  # forward to.
  def ff? *args
    p = pos 
    p1 = ff(*args)
    p1.nil? ? p1 = nil : p1 = pos
    seek p
    return p1
  end
  # rewind until it finds one of args
  # supplied as string or regex 
  # returns nil if nothing found 
  def rew *args
    p = pos
    psearch = p
    re = Regexp.union(args)
    @find_registry = { :method => :rew, :re => re }
    begin
      break if psearch == 0
      512 > pos ? buffer = pos : buffer = 512 # buffer = [512, p].min
      seek(-buffer, 1)
      psearch = pos
      chunk = read(buffer+80)
      seek(-chunk.length, 1)
      check = chunk.rindex(re)
      if !check.nil? and buffer <= check
        chunk.slice!(-(chunk.length-buffer)..-1)
        check = chunk.rindex(re)
      end
    end while check.nil? or buffer <= check 
    begin
      if buffer <= check
        seek p
        return nil
      else 
        seek(psearch + check)
        return self
      end
    rescue
      seek p
      return nil
    end
  end
  # fast forward until it finds one of args
  # supplied as string or regex 
  # returns nil if nothing found 
  def ff *args
    p = pos
    re = Regexp.union(args)
    @find_registry = { :method => :ff, :re => re }
    buffer = 512
    begin
      psearch = pos
      chunk = read(buffer)
      seek(-80,1) unless eof?
      check = chunk.index(re)
    end while check.nil? and !eof?
    begin
      seek(psearch + check)
      return self
    rescue
      seek p
      return nil
    end
  end
  # unix head like utility, returns lines
  # as an array. optional arguments cur for
  # start from current line (default is start)
  # from beggining; reset for do not change
  # current position (default).
  def head(n, cur=false, reset=true)
    #eof guard
    p = pos
    line_start
    lines = []
    seek(0) unless cur
    for i in 1..n 
      break if eof?
      lines.push(readline.chomp)
    end
    seek(p) if reset
    return lines
  end
  # unix tail like utility, returns lines
  # as an array. optional arguments cur for
  # start from current line (default is start)
  # from end; reset for do not change
  # current position (default).
  def tail(n, cur=false, reset=true)
    p = pos
    chunks = ''
    lines = 0
    cur ? line_end : seek(size)
    begin
      p1 = pos
      p1 < 512 ? buffer = p1 : buffer = 512
      seek(-buffer, 1)
      chunk = read(buffer)
      lines += chunk.count("\n")
      chunks = chunk + chunks
      seek(-chunk.size,1)
    end while lines < ( n + 1 ) && p1 != 0
    ary = chunks.split(/\n/)
    reset ? seek(p) : seek(p1-1-(ary.last(n).join("\n").length))
    return ary.last(n)
  end
  # move to the first char of current line
  def line_start
    unless readchar == "\n"
      return rew(/^/)
    end
    return self
  end
  # move to the last char of current line
  def line_end
    return ff(/$/)
  end
end
