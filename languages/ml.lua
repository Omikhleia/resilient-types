SILE.hyphenator.languages["ml"] = {}
SILE.hyphenator.languages["ml"].patterns = {
   -- GENERAL RULE
   -- Do not break either side of ZERO-WIDTH JOINER  (U+200D)
   "2‍2",
   -- Break on both sides of ZERO-WIDTH NON JOINER  (U+200C)
   "1‌1",
   -- Break before or after any independent vowel.
   "1അ1",
   "1ആ1",
   "1ഇ1",
   "1ഈ1",
   "1ഉ1",
   "1ഊ1",
   "1ഋ1",
   "1ൠ1",
   "1ഌ1",
   "1ൡ1",
   "1എ1",
   "1ഏ1",
   "1ഐ1",
   "1ഒ1",
   "1ഓ1",
   "1ഔ1",
   -- Break after any dependent vowel, but not before.
   "ാ1",
   "ി1",
   "ീ1",
   "ു1",
   "ൂ1",
   "ൃ1",
   "െ1",
   "േ1",
   "ൈ1",
   "ൊ1",
   "ോ1",
   "ൌ1",
   "ൗ1",
   -- Break before or after any consonant.
   "1ക",
   "1ഖ",
   "1ഗ",
   "1ഘ",
   "1ങ",
   "1ച",
   "1ഛ",
   "1ജ",
   "1ഝ",
   "1ഞ",
   "1ട",
   "1ഠ",
   "1ഡ",
   "1ഢ",
   "1ണ",
   "1ത",
   "1ഥ",
   "1ദ",
   "1ധ",
   "1ന",
   "1പ",
   "1ഫ",
   "1ബ",
   "1ഭ",
   "1മ",
   "1യ",
   "1ര",
   "1റ",
   "1ല",
   "1ള",
   "1ഴ",
   "1വ",
   "1ശ",
   "1ഷ",
   "1സ",
   "1ഹ",
   -- Do not break before anusvara, visarga
   "2ഃ1",
   "2ം1",
   -- Do not break either side of virama (may be within conjunct).
   "2്2",
   -- Do not break left side of chillu
   "ന്2",
   "ര്2",
   "ള്2",
   "ല്2",
   "ക്2",
   "ണ്2",
   "2ന്‍",
   "2ല്‍",
   "2ള്‍",
   "2ണ്‍",
   "2ര്‍",
   "2ക്‍",
   "2ൺ",
   "2ൻ",
   "2ർ",
   "2ൽ",
   "2ൾ",
   "2ൿ",
}
