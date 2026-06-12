#!/usr/bin/luajit

local lfs = require("lfs")
local OParser = require("oparse")
local json = require("dkjson")
local req = require("http.request")

local home = os.getenv("HOME")
local dir = home .. "/.config/krsln-onews"

local config_file = io.open(dir .. "/onews.json", "r")
local config_txt

if config_file then
	config_txt = config_file:read("*a")
else
	assert(lfs.mkdir(dir))
	config_file = assert(io.open(dir .. "/onews.json", "w"))

	config_txt = json.encode({
		address = "https://bilimolimpiyatlari.tubitak.gov.tr/tr/duyurular",
		action = "DISPLAY=:0 notify-send -u critical '<<SUMMARY>>' '<<BODY>>'",
		summary = "Bilim Olimpiyatları",
		log_file = home .. "/.krsln-onews.log",
		sanitize_pattern = "'",
		sanitize_substitute = "`"
	}, { indent = true })

	assert(config_file:write(config_txt))
end

config_file:close()
local config = assert(json.decode(config_txt))

local seq = config.container_sequence or { --see oparsecli.lua
	"<div [^>]*class=['\"]announcements%-list['\"][^>]*>(.-</date>%s*</div>%s*</div>)%s*</div>%s*</div>%s*</div>%s*</section>",
	"<div [^>]*class=['\"]item nso['\"][^>]*>(.-</div>).-</div>",
	"<div [^>]*class=['\"]wrapper['\"][^>]*>(.-)</div>",
	"<h2[^>]*>(.-)</h2>"
}

local site = config.address

local parser = OParser.new(seq)

local history_file = assert(io.open(dir .. "/history", "a+"))
history_file:seek("set")

local history_txt = history_file:read("*a")
local present_news = {}

for v in history_txt:gmatch("([^\n]+)\n") do
	present_news[v] = true
end

local log_file = assert(io.open(config.log_file, "a"))
local function log(...)
	log_file:write(tostring(os.time()), ": ", ...)
end

log("onews started\n")

local headers, stream = assert(req.new_from_uri(site):go())
assert(headers:get(":status") == "200")

local news_body = assert(stream:get_body_as_string())
local list = parser:parse(news_body)

assert(#list <= 100, "wrong output")

local s_pat = config.sanitize_pattern
local s_sub = config.sanitize_substitute

local function sanit(s)
	return (s:gsub(s_pat, s_sub))
end

for _, v in pairs(list) do
	if not present_news[v] then
		local success, ret = pcall(function()
			os.execute(
				config.action
					:gsub("<<SUMMARY>>", sanit(config.summary))
					:gsub("<<BODY>>", sanit(v))
			)

			history_file:write(v, "\n")
		end)
		if success then log('processed news "', v, '"\n')
		else log('could not process news "', v, ":", ret, '"\n')
		end
	end
end

log("onews ran successfullly")

log_file:close()
history_file:close()
