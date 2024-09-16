SILE = require("core.sile")

local CslLocale = require("csl.core.locale").CslLocale
local CslStyle = require("csl.core.style").CslStyle
local CslEngine = require("csl.core.engine").CslEngine

describe("CSL engine", function ()
   local locale, err1 = CslLocale.read("csl/locales/locales-en-US.xml")
   local style, err2 = CslStyle.read("csl/styles/chicago-author-date.csl")

   local cslentryJungle = {
      type = "paper-conference",
      ["citation-key"] = "jungle2024",
      ["citation-number"] = 1,
      author = {
         {
            family = "Smith",
            ["family-short"] = "S",
            given = "George",
            ["given-short"] = "G",
         }
      },
      title = "Article title",
      page = "10-20",
      issued = {
         year = "2024"
         },
      publisher = "Publisher",
      ["publisher-place"] = "Place",
      volume = "10",
      editor = {
         {
            family = "Doe",
            ["family-short"] = "D",
            given = "Jane",
            ["given-short"] = "J",
         }
      },
      locator = {
         label = "page",
         value = "30-35"
      },
      ["collection-number"] = "3",
      ["collection-title"] = "Series",
      ["container-title"] = "Book Title",
   }

   it("should parse locale and style", function ()
      assert.is.falsy(err1)
      assert.is.falsy(err2)
      assert.is.truthy(locale)
      assert.is.truthy(style)
   end)

   it("should render a citation", function ()
      local engine = CslEngine(style, locale)
      local citation = engine:cite(cslentryJungle)
      assert.is.equal("(Smith 2024, 30–35)", citation)
   end)

   it ("should render a reference", function ()
      local engine = CslEngine(style, locale)
      local reference = engine:reference(cslentryJungle)
      assert.is.equal(
         "Smith, George. 2024. “Article title.” In <em>Book Title,</em> edited by Jane Doe, 10:10–20. Series 3. Place: Publisher.",
         reference)
   end)
end)
