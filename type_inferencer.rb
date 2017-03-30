require_relative 'types'
require_relative 'ast'

class TypeInferencer
  class << self
    def type(ast)
      c = constraints({}, 0, ast)
      s = solve(c[:c])
      apply(s, c[:t])
    end

    private

    def constraints(env, fv, ast)
      case ast
      when ENum
        return { t: TNum.new, c: [], fv: fv }
      when EBool
        return { t: TBool.new, c: [], fv: fv }
      when EVar
        unless env[ast.x]
          raise "EVar: unknown #{ast.x}"
        end
        return { t: env[ast.x], c: [], fv: fv }
      when EIf
        c = constraints env, fv, ast.c
        e1 = constraints env, c[:fv], ast.e1
        e2 = constraints env, e1[:fv], ast.e2
        return {
          t: e1[:t],
          c: c[:c] + e1[:c] + e2[:c] + [[c[:t], TBool.new], [e1[:t], e2[:t]]],
          fv: e2[:fv]
        }
      when EFun
        t = TVar.new("x#{fv}")
        dup = env.dup.merge ast.x => t
        e = constraints dup, fv + 1, ast.e
        return {
          t: TFun.new(t, e[:t]),
          c: e[:c],
          fv: e[:fv]
        }
      when ECall
        f = constraints env, fv, ast.f
        e = constraints env, f[:fv], ast.e
        t = TVar.new("x#{e[:fv]}")
        return {
          t: t,
          c: f[:c] + e[:c] + [[f[:t], TFun.new(e[:t], t)]],
          fv: e[:fv] + 1
        }
      when EBinop
        e1 = constraints env, fv, ast.e1
        e2 = constraints env, e1[:fv], ast.e2
        case ast.op
        when "+", "-", "*", "/", "%"
          return {
            t: TNum.new,
            c: e1[:c] + e2[:c] + [[e1[:t], TNum.new], [e2[:t], TNum.new]],
            fv: e2[:fv]
          }
        when "<", ">", "<=", ">=", "==", "!="
          return {
            t: TBool.new,
            c: e1[:c] + e2[:c] + [[e1[:t], TNum.new], [e2[:t], TNum.new]],
            fv: e2[:fv]
          }
        when "&&", "||"
          return {
            t: TBool.new,
            c: e1[:c] + e2[:c] + [[e1[:t], TBool.new], [e2[:t], TBool.new]],
            fv: e2[:fv]
          }
        end
      when ECons
        hd = constraints env, fv, ast.hd
        tl = constraints env, hd[:fv], ast.tl
        return {
          t: TList.new(hd[:t]),
          c: hd[:c] + tl[:c] + [[tl[:t], TList.new(hd[:t])]],
          fv: tl[:fv]
        }
      when ENil
        return {
          t: TList.new(TVar.new("x#{fv}")),
          c: [],
          fv: fv + 1
        }
      else
        raise "Unknow ast type"
      end
    end

    def substitute(x, t, s)
      case s
      when TNum, TBool
        s
      when TVar
        x == s.x ? t : s
      when TFun
        TFun.new((substitute x, t, s.x), (substitute x, t, s.e))
      when TList
        TList.new(substitute x, t, s.t)
      end
    end

    def apply(sub, s)
      sub.reduce(s) do |t, pair|
        substitute pair[0], pair[1], t
      end
    end

    def unify(t1, t2)
      case [t1.class, t2.class]
      when [TNum, TNum]
        return []
      when [TBool, TBool]
        return []
      when [TFun, TFun]
        return solve [[t1.x, t2.x], [t1.e, t2.e]]
      when [TList, TList]
        return solve [[t1.t, t2.t]]
      else
        if t1.class == TVar && !appears(t1.x, t2)
          return [[t1.x, t2]]
        elsif t2.class == TVar && !appears(t2.x, t1)
          return [[t2.x, t1]]
        end
      end

      raise "Cannot unify #{t1} and #{t2}"
    end

    def solve(cons)
      cons.reduce([]) do |sub, pair|
        t1, t2 = pair
        sub + (unify (apply sub, t1), (apply sub, t2))
      end
    end

    def appears(x, t)
      case t
      when TNum, TBool
        return false
      when TVar
        return x == t.x
      when TFun
        return appears(x, t.x) || appears(x, t.e)
      when TList
        return appears(x, t.t)
      end
    end
  end
end
