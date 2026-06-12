#!/usr/bin/luajit
--Utility that inserts backslashes as needed for the first macro it finds.
--Assumes that all occurences of the string "#define" are at the beginning of their respective lines.
--Also assumes that lines containing #define contain no tabs.
--Also assumes that all tabs can translate to 8 spaces. This is the case when tabs are used for indentation, but may not be so if they're in code lines.
--Does not care about the last line or details like that.

local buf = io.read("*a") .. "\0"
local tabsize = 8

--                 [  match the line  ]      [match the ending]
local v = buf:gsub("(#define [^\n\\]*\\)(%s-)(\n.-\n)([^%s])", function (line, s, contents, violating)
	local bs_pos = #line

	return line .. s .. contents:gsub("\n([^\n]*)", function(part)
		if part:match("\\%s*$") then return "\n" .. part end

		local _, n_tabs = part:gsub("\t", "")
		local remaining = bs_pos - (#part + (tabsize - 1) * n_tabs)
		if remaining <= 1 then return "\n" .. part .. " \\" end
		return "\n" .. part .. string.rep(" ", remaining - 1) .. "\\"
	end) .. "\n" .. violating
end, 1)

io.write(v:sub(1, #v - 1))
