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

local enumtypes = {
  e8 = "sint8",
  e16 = "sint16",
  e32 = "sint32",
}

local printtypes = {
  i8 = "sint8",
  u8 = "uint8",
  i16 = "sint16",
  u16 = "uint16",
  i32 = "sint32",
  u32 = "uint32",
  i64 = "sint64",
  u64 = "uint64",
  d = "double",
  f = "float",
  e8 = 'sint8',
  e16 = 'sint8',
  e32 = 'sint32',

  p = "pointer",
  s = "pointer",
}

local math = require('math')
local printvalues = {
  i8 = 0xff,
  u8 = 0xff,
  i16 = 0xffff,
  u16 = 0xffff,
  i32 = 0xffffffff,
  u32 = 0xffffffff,
  i64 = 0xffffffffffffffff,
  u64 = 0xffffffffffffffff,
  d = math.pi,
  f = math.pi,
  e8 = 0xff,
  e16 = 0xffff,
  e32 = 0xffffffff,

  --p = ffi.NULL,
  s = "pointer",
}

local real_funcs = { "add" }

local lib = {}

do
  local cif
  for k, v in pairs(inttypes) do
    cif = ffi.cif {ret = ffi[v]; ffi[v], ffi[v]}
    for _, f in ipairs(real_funcs) do
      lib[string.format('%s_%s', f, k)] = cif
    end
  end
  for k, v in pairs(floattypes) do
    cif = ffi.cif {ret = ffi[v]; ffi[v], ffi[v]}
    for _, f in ipairs(real_funcs) do
      lib[string.format('%s_%s', f, k)] = cif
    end
  end

  cif = ffi.cif {ret = ffi.sint, ffi.sint}
  lib.test_pow = cif

  for k, v in pairs(enumtypes) do
    cif = ffi.cif {ret = ffi[v]; ffi[v]}
    lib[string.format('inc_%s', k)] = cif
  end

  -- EXPORT int NAME(char* buf, TYPE val); \
  for k, v in pairs(printtypes) do
    cif = ffi.cif {ret = ffi.sint; ffi.pointer, ffi[v]}
    lib[string.format('print_%s', k)] = cif
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

check(4, lib.test_pow(2), "test_pow")

local enumvalues = {
  e8 = 0xff,
  e16 = 0xffff,
  e32 = 0xffffffff
}

for k, _ in pairs(enumtypes) do
  local func = string.format("inc_%s", k)
  check(0, lib[func](enumvalues[k]), func)
end

for k, v in pairs(printtypes) do
  local func = string.format("print_%s", k)
  local buf = ffi.alloc(ffi.char, 128)
  local l = lib[func](buf, printvalues[k])
  assert(l > 0 and l < 128)
  buf = ffi.tostring(buf)
  check(l, #buf, buf)
end

print(string.format('Test PASS %%%.2d fail/total %d/%d', fail/count, fail, count))
