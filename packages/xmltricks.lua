SILE.registerCommand("xmltricks:ignore", function (_, content)
  for token in SU.gtoke(content[1]) do
    if token.string then SILE.call("define", { command = token.string}, function() end) end
  end
end)

SILE.registerCommand("xmltricks:passthru", function (_, content)
  for token in SU.gtoke(content[1]) do
    if token.string then SILE.registerCommand(token.string, function(_, c) SILE.process(c) end) end
  end
end)
