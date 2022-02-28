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
  SILE.call("font", { family = "Libertinus Sans" }, content)
end)

SILE.registerCommand("autodoc:command", function (options, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  local name = type(content[1] == "string") and content[1] or content[1].command
  if not name then SU.error("Unexpected command "..name) end

  local pkgname = options.package

  if name:sub(1,1) == "\\" then
    name = name:sub(2)
  end
  local cmd = SILE.Commands[name]
  if not cmd then SU.error("Unknown command "..name) end

  local location = SILE.Help[name].where
  print("-----------autodoc command "..name.." from "..location)
  SILE.call("xcode", {}, { "\\"..name })
end, "Outputs a command name in code, checking its validity.")

SILE.registerCommand("autodoc:environment", function (options, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  local name = type(content[1] == "string") and content[1] or content[1].command
  if not name then SU.error("Unexpected command "..name) end

  local pkgname = options.package

  if name:sub(1,1) == "\\" then
    name = name:sub(2)
  end
  local cmd = SILE.Commands[name]
  if not cmd then SU.error("Unknown command "..name) end

  local location = SILE.Help[name].where
  print("-----------autodoc environment "..name.." from "..location)
  SILE.call("xcode", {}, { name })
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

  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected setting "..name) end

  local setting = SILE.settings.get(name) -- will issue an error if unknown
  
  -- Inserts breakpoints after dots
  local nameWithBreaks = inputfilter.transformContent(content, settingFilter)
  print("-----------autodoc setting "..name)
  SILE.call("xcode", {}, nameWithBreaks)
end, "Outputs a settings name in code, checking its validity.")

SILE.registerCommand("autodoc:param", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end

  print("-----------autodoc option "..name)
  SILE.call("xcode", {}, { name })
end, "Outputs a settings name in code, checking its validity.")

SILE.registerCommand("autodoc:package", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end

  print("-----------autodoc package "..name)
  SILE.call("xcode", {}, { name })
end, "Outputs a package name in code, checking its validity.")

SILE.registerCommand("autodoc:function", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end

  print("-----------autodoc function "..name)
  SILE.call("xcode", {}, { name })
end, "Outputs a function name in code, checking its validity.")

SILE.registerCommand("autodoc:class", function (_, content)
  if type(content) ~= "table" then SU.error("Expected a table content") end
  if #content ~= 1 then SU.error("Expected a single element") end

  local name = type(content[1] == "string") and content[1]
  if not name then SU.error("Unexpected option "..name) end

  print("-----------autodoc class "..name)
  SILE.call("xcode", {}, { name })
end, "Outputs a class name in code, checking its validity.")

SILE.registerCommand("autodoc:code", function (_, content)
  SILE.call("xcode", {}, content)
end, "Outputs a class name in code, checking its validity.")

SILE.registerCommand("autodoc:value", function (_, content)
  SILE.call("xcode", {}, content)
end, "Outputs a class name in code, checking its validity.")

return {
  documentation = [[\begin{document}
This package extracts documentation from other packages. It’s used to
construct the SILE documentation. Doing this allows us to keep the
documentation near the implementation, which (in theory) makes it easy
for documentation and implementation to be in sync.
\end{document}]]
}
