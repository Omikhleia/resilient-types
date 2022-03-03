SILE.require("packages/verbatim")
SILE.require("packages/rules")
if not SILE.Commands["line"] then
  SILE.doTexlike([[%
  \define[command=line]{\par\smallskip\noindent\hrule[width=450pt, height=0.3pt]\par
  \novbreak\smallskip\novbreak}
  ]])
end
if not SILE.Commands["examplefont"] then
  SILE.doTexlike([[%
  \define[command=examplefont]{\process}
  ]])
end

SILE.registerCommand("package-documentation", function (options, _)
  local package = SU.required(options, "src", "src for package documentation")
  SU.debug("autodoc", package)
  local exports = require(package)
  if type(exports) ~= "table" or not exports.documentation then
    SU.error("Undocumented package "..package)
  end
  SILE.process(
    SILE.inputs.TeXlike.docToTree(
      exports.documentation
    )
  )
end, "Outputs the documentation from a package.")

SILE.require("packages/color")
if not SILE.Commands["code"] then
  SILE.registerCommand("code", function(options, content)
    SILE.call("color", { color = "red" }, function ()
      SILE.process(content)      
    end)
  end)
end
if not SILE.Commands["note"] then
  SILE.registerCommand("note", function(options, content)
    SILE.call("color", { color = "red" }, function ()
      SILE.process(content)      
    end)
  end)
end

SILE.registerCommand("xcode", function(options, content)
  -- NOTE: options.kind contains one of "command", "setting"
  -- If redefining this command, it allows distinguishing the various types.
  SILE.call("color", { color = "darkolivegreen" }, function ()
    SILE.call("font", { family = "Hack", size = SILE.settings.get("font.size") - 2 }, content)
  end)
end)

SILE.registerCommand("autodoc:command", function (options, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Be error-prone: accept the user to have entered the content as \\cmd, cmd
  -- (i.e. strings, prepended or not with \\) or even as \cmd (i.e. table, as
  -- it will have been parsed to AST).
  -- Then retrieve the actual raw command name.
  local name = type(content[1]) == "string" and content[1] or content[1].command
  if not name then SU.error("Unexpected command "..name) end
  if name:sub(1,1) == "\\" then
    name = name:sub(2)
  end
  -- Check validity
  local cmd = SILE.Commands[name] or SU.error("Unknown command "..name)
  -- Enforce the \ at output
  SILE.call("xcode", { kind = "command" }, { "\\"..name })
end, "Outputs a formatted command name, checking its validity.")

SILE.registerCommand("autodoc:environment", function (options, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Similar to autodoc:command but expect a direct string only
  local name = type(content[1]) == "string" and content[1]
  if not name then SU.error("Unexpected command "..name) end
  -- Check validity
  local cmd = SILE.Commands[name] or SU.error("Unknown command "..name)

  SILE.call("xcode", { kind = "command" }, { name })
end, "Outputs a command name in code, checking its validity.")

local inputfilter = SILE.require("packages/inputfilter").exports
local settingFilter = function (node, content)
  if type(node) == "table" then return node end
  local result = {}
  for token in SU.gtoke(node, "[%.]") do
    if token.string then
      result[#result+1] = token.string
    else
        result[#result+1] = token.separator
        result[#result+1] = inputfilter.createCommand(
          content.pos, content.col, content.line,
          "penalty", { penalty = 100 }, nil
        )
    end
  end
  return result
end
SILE.registerCommand("autodoc:setting", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Expect a direct string only
  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected setting "..name) end
  -- Check validity
  local setting = SILE.settings.get(name) -- will issue an error if unknown
  -- Inserts breakpoints after dots
  local nameWithBreaks = inputfilter.transformContent(content, settingFilter)

  SILE.call("xcode", { kind = "setting" }, nameWithBreaks)
end, "Outputs a settings name in code, checking its validity.")

SILE.registerCommand("autodoc:param", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Expect a direct string only
  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end
  -- As of yet, there is no way to check a parameter/option is valid.
  -- Moreover, it's common to have options passed from a command to some
  -- other command it calls, so there might not be a doable way to
  -- achieve verification.

  SILE.call("xcode", { kind = "param" }, { name })
end, "Outputs a settings name in code, checking its validity.")

SILE.registerCommand("autodoc:package", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Expect a direct string only
  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end
  -- We do not check package name to exist!

  SILE.call("xcode", { kind = "package" }, { name })
end, "Outputs a package name in code, checking its validity.")

SILE.registerCommand("autodoc:function", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Expect a direct string only
  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end
  -- We do not check anything here. Additional possibilities would
  -- be to check for parentheses (for output consistency), and possibly
  -- to check the package actually exports the referred function.
  SILE.call("xcode", { kind = "function" }, { name })
end, "Outputs a function name in code, checking its validity.")

SILE.registerCommand("autodoc:class", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  -- Expect a direct string only
  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end
  -- We do not check class name to exist!

  SILE.call("xcode", { kind = "class" }, { name })
end, "Outputs a class name in code, checking its validity.")

SILE.registerCommand("autodoc:code", function (_, content)
  SILE.call("xcode", { kind = "code" }, content)
end, "Outputs a class name in code, checking its validity.")

SILE.registerCommand("autodoc:value", function (_, content)
  SILE.call("xcode", {}, content)
end, "Outputs a class name in code, checking its validity.")

SILE.doTexlike([[%
\define[command=autodoc:args]{\autodoc:code{⟨\em{\process}\kern[width=0.1em]⟩}}
\define[command=autodoc:note]{\medskip
\set[parameter=document.lskip,value=24pt]
\set[parameter=document.rskip,value=24pt]
\par\goodbreak\noindent\hrule[width=100%lw,height=0.75pt]\par
\medskip\noindent\process\par\smallskip\noindent\hrule[width=100%lw,height=0.75pt]\par
\set[parameter=document.lskip,value=0pt]\medskip
}
]])

return {
  documentation = [[\begin{document}
This package extracts documentation from other packages. It’s used to
construct the SILE documentation. Doing this allows us to keep the
documentation near the implementation, which (in theory) makes it easy
for documentation and implementation to be in sync.

For that purpose, it provides the
\autodoc:command{\\package-documentation}\autodoc:code{[src=\autodoc:args{package}]}
command.

\autodoc:command{package-documentation}
\autodoc:command{\\package-documentation}
\autodoc:command{\package-documentation}

Properly documented packages should export a \autodoc:code{documentation} string
containing their documentation, as a SILE document.

For documenters and package designers, it also provides commands that can be used in their package
documentations to present various pieces of information in a consistent way:
\autodoc:command{autodoc:command} typesets the given command name (checking its existence
and adding the initial \autodoc:code{\\} if missing),
\autodoc:command{autodoc:environment} does the same for an environment (as a convenience),
\autodoc:command{autodoc:setting} typesets the given setting (parameter) name (checking
its existence and automatically adding some breakpoints to ease line-breaking),
\autodoc:command{autodoc:param}, \autodoc:command{autodoc:package}, \autodoc:command{autodoc:class},
\autodoc:command{autodoc:function} may be used to respectively typeset a command option (parameter) name,
a package name, a class name, an exported package function name (without any checks as of yet).

The generic \autodoc:command{autodoc:code} simply outputs its content as code, without any of
the above subtleties.

\autodoc:command{\\autodoc:args} and
commmands to be used in package documentations to respectively present a command (checking its name),
and parameter argument values and keywords.
The two first ware used just above, the last is intended for package
name or other information that might be represented with a different
font.

\end{document}]]
}
