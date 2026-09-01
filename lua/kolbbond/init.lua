-- Order matters: set.lua defines mapleader, so it must precede remap.lua.
-- lazy.setup() is deliberately NOT here -- lua/init.lua runs it last, after
-- every option and plugin global is in place.
require("kolbbond.set")
require("kolbbond.remap")
require("kolbbond.autoreload")
