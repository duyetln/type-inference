class AST; end

class ENum < AST
  attr_reader :n
  def initialize(n)
    @n = n
  end

  def to_s
    "ENum(#{n})"
  end
end

class EBool < AST
  attr_reader :b
  def initialize(b)
    @b = b
  end

  def to_s
    "EBool(#{b})"
  end
end

class EVar < AST
  attr_reader :x
  def initialize(x)
    @x = x
  end

  def to_s
    "EVar(#{x})"
  end
end

class EIf < AST
  attr_reader :c
  attr_reader :e1
  attr_reader :e2
  def initialize(c, e1, e2)
    @c = c
    @e1 = e1
    @e2 = e2
  end

  def to_s
    "EIf(#{c}, #{e1}, #{e2})"
  end
end

class EFun < AST
  attr_reader :x
  attr_reader :e
  def initialize(x, e)
    @x = x
    @e = e
  end

  def to_s
    "EFun(#{x}, #{e})"
  end
end

class ECall < AST
  attr_reader :f
  attr_reader :e
  def initialize(f, e)
    @f = f
    @e = e
  end

  def to_s
    "EFun(#{f}, #{x})"
  end
end

class EBinop < AST
  attr_reader :op
  attr_reader :e1
  attr_reader :e2
  def initialize(op, e1, e2)
    @op = op
    @e1 = e1
    @e2 = e2
  end

  def to_s
    "EBinop(#{op}, #{e1}, #{e2})"
  end
end

class ECons < AST
  attr_reader :hd
  attr_reader :tl
  def initialize(hd, tl)
    @hd = hd
    @tl = tl
  end

  def to_s
    "ECons(#{hd}, #{tl})"
  end
end

class ENil < AST
  def to_s
    "ENil"
  end
end
