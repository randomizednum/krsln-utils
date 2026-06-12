#!/usr/bin/env lua
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
        --print("hi", self.container_sequence.val, self.container_sequence.nextstr)

        local list = {}

        local next_container = self.container_sequence.next

        if not next_container then
                --print("uhh")
                for v in string.gmatch(str, self.container_sequence.val) do table.insert(list, v) end
                return list
        end

        local inner_parser = OParser.new()
        inner_parser.container_sequence = next_container

        for v in string.gmatch(str, self.container_sequence.val) do
                --print("hey lol", v)
                for _, inner_element in ipairs(inner_parser:parse(v)) do
                        table.insert(list, inner_element)
                end
        end

        return list
end

if arg then --CLI-related code
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
end

return OParser
