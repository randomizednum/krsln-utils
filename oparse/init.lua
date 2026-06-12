--"Parses" https://bilimolimpiyatlari.tubitak.gov.tr/tr/duyurular or alternatively some other site
--Short for "Olympiad parser" but can be used for most other simple announcement websites too if a container sequence for that is given

local OParser = {
	--Default values

	--Table values; these must be set in OParser.new since otherwise the table would be shared
	--container_sequence = {}, --A linked list of string.match patterns with captures; each capture from one pattern is the match string for the next pattern. OParser:parse will get into any depth within paths that can be created using this sequence of "containers" and return the last capture.
}
OParser.__index = OParser

local function to_linked_list(arr)
	local original_t = {}
	t = original_t
	for i, v in ipairs(arr) do
		t.val = v
		if i == #arr then break end
		local next_t = {}
		t.next = next_t
		t = next_t
	end

	return original_t
end

function OParser.new(init_sequence)
	return setmetatable({
		container_sequence = init_sequence and to_linked_list(init_sequence)
	}, OParser)
end

function OParser:parse(str)
	local list = {}

	local next_container = self.container_sequence.next

	if not next_container then
		for v in string.gmatch(str, self.container_sequence.val) do table.insert(list, v) end
		return list
	end

	local inner_parser = OParser.new()
	inner_parser.container_sequence = next_container

	for v in string.gmatch(str, self.container_sequence.val) do
		for _, inner_element in ipairs(inner_parser:parse(v)) do
			table.insert(list, inner_element)
		end
	end

	return list
end

return OParser
