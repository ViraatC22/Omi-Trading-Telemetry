local M = {}
function M.band(a, b) return a & b end
function M.bor(a, b) return a | b end
function M.bxor(a, b) return a ~ b end
function M.lshift(a, n) return a << n end
function M.rshift(a, n) return a >> n end
return M
