# Lua FFI

## Usage

1. load `ffi` module by `require('ffi')`
2. define `cif` by `ffi.cif({ret=ffi.ctype, ...})`, `...` are list paramaters `ffi.ctype`.
3. make a `table` named `lib` contains `c_api` symbol as key, and `cif` as value.
4. load `cmodule` by call `ffi.loadlib('name', lib)`, that return a `table` which convert all `cif` to `lua function`.
5. call function in `cmodule` indexed by `c_api` symbol.

## Features

1. Lua calling C functions
2. C calling Lua closures (callbacks)
3. Mutable Arrays
4. Structs

## Status

Untested, incompelete.  Sufficient for my personal use.
