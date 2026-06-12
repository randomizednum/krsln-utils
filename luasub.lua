#!/usr/bin/env lua

--A simple script that applies a Lua pattern to each of its arguments and prints them to stdout.

local usage = "Usage: luasub [OPTION]... STRING... PATTERN REPLACEMENT\nApplies the Lua pattern to all arguments and writes the results to standard output.\n\nOptions:\n\t-e: Attempts to escape the resulting strings, so that they can safely be interpreted by shells.\n\t-n: Sets the maximum number of replacements per string. Must be followed by a number.\n\t-s: Sets the separator to use. Default is a newline. Must be followed by the separator to use.\n\nNotes: Different Lua versions may have slight differences in how string.gsub works; this is reflected in this program.\n"

--A few utility functions.
local function switch(value)
	return function(cases)
		if cases[value] then return cases[value](value)
		elseif cases.default then return cases.default(value) end
	end
end

--Variables.
local pattern, replacement, num_match
local separator = "\n"
local escape = false
local strings = {}

local i = 1
local process_options = true

while i <= #arg do
	local this = arg[i]

	if process_options and this:sub(1, 1) == "-" then
		for j = 2, #this do
			local char = this:sub(j, j)
			switch(char) {
				["e"] = function() escape = true end,
				["s"] = function()
					if j ~= #this or i == #arg then io.write(usage) os.exit(false) end

					i = i + 1
					separator = arg[i]
				end,
				["n"] = function()
					if j ~= #this or i == #arg then io.write(usage) os.exit(false) end

					i = i + 1
					num_match = tonumber(arg[i])
					if not num_match then io.write(usage) os.exit(false) end
				end,
				["-"] = function() process_options = false end,
				["default"] = function() io.write(usage) os.exit(false) end
			}
		end
	else
		table.insert(strings, this)
	end
	i = i + 1
end

if #strings < 3 then io.write(usage) os.exit(false) end
replacement = table.remove(strings)
pattern = table.remove(strings)

--print(pattern, replacement, separator, escape)

--Escapes the string to make it safe to be put into a POSIX shell.
--Does not escape "!"; this must be considered when using Bash.
local escape_forbidden = { ['"'] = true, ["\\"] = true, ["`"] = true, ["$"] = true } --Forbidden characters that must be escaped.
local function escape_string(s)
	local new_s = '"'
	for i = 1, #s do
		local char = s:sub(i, i)

		if escape_forbidden[char] then new_s = new_s .. "\\" end
		new_s = new_s .. char
	end
	new_s = new_s .. '"'
	return new_s
end

for _, v in ipairs(strings) do
	local result = v:gsub(pattern, replacement, num_match)
	if escape then result = escape_string(result) end
	io.write(result, separator)
	--num_match helps account for differences between Lua 5.2 (and before) and Lua 5.3 (and after).
	--For example, older versions will match a final empty string if they can, which could be prevented with this.
end
