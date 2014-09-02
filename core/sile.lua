SILE = {}
SILE.version = "0.9.0"
SILE.utilities = require("core/utilities")
SU = SILE.utilities
SILE.inputs = {}
SILE.Commands = {};
SILE.debugFlags = {}

std = require("std")

SILE.documentState = std.object {};
SILE.scratch = {};
SILE.length = require("core/length")
require("core/parserbits")
require("core/measurements")
require("core/baseclass")
SILE.nodefactory = require("core/nodefactory")
require("core/settings")
require("core/inputs-texlike")
require("core/inputs-xml")
require("core/inputs-common")
require("core/pango-shaper")
require("core/papersizes")
require("core/colorparser")
require("core/pagebuilder")
require("core/typesetter")
require("core/hyphenator-liang")
require("core/font")

SILE.frameParser = require("core/frameparser")
SILE.linebreak = require("core/break")

require("core/frame")
require("core/cairo-output")

SILE.require = function(d)
  -- path?
  return require(d)
end

SILE.parseArguments = function()
local parser = std.optparse ("This is SILE "..SILE.version..[[

 Usage: sile

 Banner text.

 Optional long description text to show when the --help
 option is passed.

 Several lines or paragraphs of long description are permitted.

 Options:

   -d, --debug=VALUE        debug SILE's operation
   -I, --include=[FILE]     accept an optional argument
       --version            display version information, then exit
       --help               display this help, then exit
]])

  parser:on ('--', parser.finished)
  _G.arg, _G.opts = parser:parse(_G.arg)
  SILE.debugFlags = {}
  if opts.debug then
    for k,v in ipairs(std.string.split(opts.debug, ",")) do SILE.debugFlags[v] = 1 end
  end
  if opts.include then
    SILE.preamble = true
    -- Try a .sil
    print("Loading "..opts.include)
    local i = SILE.resolveFile(opts.include)
    if i then
      SILE.readFile(i)
    else
      require("classes/"..opts.include)
    end
    SILE.preamble=false
  end
end

function SILE.initRepl ()
  SILE._repl          = require 'repl.console'
  local has_linenoise = pcall(require, 'linenoise')

  if has_linenoise then
    SILE._repl:loadplugin 'linenoise'
  else
    -- XXX check that we're not receiving input from a non-tty
    local has_rlwrap = os.execute('which rlwrap >/dev/null 2>/dev/null') == 0

    if has_rlwrap and not os.getenv 'LUA_REPL_RLWRAP' then
      local lowest_index = -1

      while arg[lowest_index] ~= nil do
        lowest_index = lowest_index - 1
      end
      lowest_index = lowest_index + 1
      os.execute(string.format('LUA_REPL_RLWRAP=1 rlwrap %q %q', arg[lowest_index], arg[0]))
      return
    end
  end

  SILE._repl:loadplugin 'history'
  SILE._repl:loadplugin 'completion'
  SILE._repl:loadplugin 'autoreturn'
  SILE._repl:loadplugin 'rcfile'
end

function SILE.repl()
  if not SILE._repl then SILE.initRepl() end
  SILE._repl:run()
end

function SILE.readFile(fn)
  SILE.currentlyProcessingFile = fn
  fn = SILE.resolveFile(fn)
  local file, err = io.open(fn)
  if not file then
    print("Could not open "..err)
    return
  end
  io.write("<"..fn..">")
  -- Sniff first few bytes
  local sniff = file:read("*l") or ""
  file:seek("set", 0)
  if sniff:find("^<") then
    SILE.inputs.XML.process(fn)
  else
    SILE.inputs.TeXlike.process(fn)
  end
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function SILE.resolveFile(fn)
  if file_exists(fn) then return fn end
  if file_exists(fn..".sil") then return fn..".sil" end

  for k in SU.gtoke(os.getenv("SILE_PATH"), ";") do
    if k.string then
      local f = std.io.catfile(k.string, fn)
      if file_exists(f) then return f end
      if file_exists(f..".sil") then return f..".sil" end
    end
  end
end

function SILE.call(cmd,options, content)
  if not SILE.Commands[cmd] then SU.error("Unknown command "..cmd) end
  SILE.Commands[cmd](options or {}, content or {})
end

return SILE
