-- vim: ts=2 sw=2 sts=2 et tw=78
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree. An additional grant
-- of patent rights can be found in the PATENTS file in the same directory.
--
io.stdout:setvbuf('no')
local ffi = require 'ffi'

local inttypes = {
  u8  = "uint8",
  u16 = "uint16",
  u32 = "uint32",
  u64 = "uint64",
  i8  = "sint8",
  i16 = "sint16",
  i32 = "sint32",
  i64 = "sint64",
}

local floattypes = {
  f = "float",
  d = "double",
  --ld = "longdouble"
}

local real_funcs = { "add" }

local lib = {}

do
  for k, v in pairs(inttypes) do
    local cif = ffi.cif {ret = ffi[v]; ffi[v], ffi[v]}
    for _, f in ipairs(real_funcs) do
      lib[string.format('%s_%s', f, k)] = cif
    end
  end
  for k, v in pairs(floattypes) do
    local cif = ffi.cif {ret = ffi[v]; ffi[v], ffi[v]}
    for _, f in ipairs(real_funcs) do
      lib[string.format('%s_%s', f, k)] = cif
    end
  end
end

local fail, count = 0, 0
local function check(a, b, msg)
    count = count + 1
    if a ~= b then
        print('check', a, b)
        fail = fail + 1
    end
    return _G.assert(a == b, msg)
end

print('Running test')

for k, v in pairs(lib) do
    print(k, v)
end

lib = ffi.loadlib('test.so', lib)

for k, _ in pairs(inttypes) do
  for _, f in ipairs(real_funcs) do
    local fun = string.format('%s_%s', f, k)
    local func = lib[fun]
    check(2, func(1, 1), fun)
  end
end

for k, _ in pairs(floattypes) do
  for _, f in ipairs(real_funcs) do
    local fun = string.format('%s_%s', f, k)
    local func = lib[fun]
    check(2, func(1, 1), fun)
  end
end

print(string.format('Test PASS %%%.2d fail/total %d/%d', fail/count, fail, count))
