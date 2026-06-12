#!/usr/bin/env lua
local OParser = require("oparse")

local file = (arg[1] and arg[1]~="-") and io.open(arg[1]) or io.input()
local sequence = (arg[2] and arg[2]~="-") and require(arg[2]) or {
	"<div [^>]*class=['\"]announcements%-list['\"][^>]*>(.-</date>%s*</div>%s*</div>)%s*</div>%s*</div>%s*</div>%s*</section>", --Since string.match doesn't support grouping characters, I had to find a hack to balance. I tried %b<\ but unluckily the website has links containing slashes, so that wouldn't work. Now I'll go with using the date tags found at every entry. This is way too hacky but it does work for this website. I need a >
	"<div [^>]*class=['\"]item nso['\"][^>]*>(.-</div>).-</div>", --Again, we can't get proper matching of nested tags, but in that specific website we can do this.
	"<div [^>]*class=['\"]wrapper['\"][^>]*>(.-)</div>", --Again, we are lucky.
	"<h2[^>]*>(.-)</h2>"
} --Since we aren't actually parsing the things, the strings are likely to fail with "unusal" input.

local text = file:read("*a")

local list = OParser.new(sequence):parse(text)
for _, v in ipairs(list) do
	io.write(v .. "\n")
end

return
