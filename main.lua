-- lsd-mtime-color.yazi
-- A Yazi linemode plugin that colors file mtimes like LSD (LSDeluxe):
--   < 1 hour ago  →  bright green
--   < 1 day ago   →  green
--   older         →  teal/cyan
--
-- Installation:
--   ya pkg add <your-repo>/lsd-mtime-color
--   OR copy this file to ~/.config/yazi/plugins/lsd-mtime-color.yazi/main.lua
--
-- Setup in ~/.config/yazi/init.lua:
--   require("lsd-mtime-color"):setup()
--   -- Optional custom thresholds (in seconds):
--   require("lsd-mtime-color"):setup({
--     hour_threshold = 3600,        -- files newer than this → bright green
--     day_threshold  = 86400,       -- files newer than this → green
--     color_hour  = "#00d700",      -- bright green
--     color_day   = "#00d787",      -- green
--     color_older = "#00af87",      -- teal
--     yazi_age_format = false,      -- show distinct detailed timestamp based on age
--     width = 12                    -- widht to use for padding timestamps
--   })
--
-- Enable in ~/.config/yazi/yazi.toml:
--   [mgr]
--   linemode = "lsd_mtime"          -- date only
--   -- or:
--   linemode = "lsd_size_mtime"     -- size + date

-- Default configuration
local DEFAULT = {
	hour_threshold = 3600, -- 1 hour in seconds
	day_threshold = 86400, -- 1 day  in seconds
	color_hour = "#00d700",
	color_day = "#00d787",
	color_older = "#00af87",
	yazi_age_format = false,
	width = 12,
}

-- Configuration from setup
local CFG = {}

-- Set color
local function colored_span(text, color)
	return ui.Span(text):fg(color)
end

-- pad strings with fixed WIDTH
local function pad(text)
	return string.format("%-" .. CFG.width .. "s", text)
end

-- Human-readable file size
local function fmt_size(file)
	local sz = file:size()
	if not sz then
		return "  -"
	end
	return ya.readable_size(sz)
end

-- Format mtime timestamp and pick mathcing color
local function fmt_mtime_colored(mtime_secs)
	local now = os.time()
	local age = now - mtime_secs
	local text, color

	if mtime_secs == 0 then
		return ui.Span(pad("")) -- empty padding
	end

	-- Pick color bracket
	if age < CFG.hour_threshold then
		color = CFG.color_hour
	elseif age < CFG.day_threshold then
		color = CFG.color_day
	else
		color = CFG.color_older
	end

	if CFG.yazi_age_format then
		-- Format string (same smart logic as linemode-plus / yazi built-in)
		local today = os.date("*t")
		local fdate = os.date("*t", mtime_secs)

		if fdate.year == today.year and fdate.month == today.month and fdate.day == today.day then
			-- Today: show time only
			text = pad(os.date("%H:%M", mtime_secs))
		elseif fdate.year == today.year then
			-- This year: show month + day + time
			text = pad(os.date("%b %d %H:%M", mtime_secs))
		else
			-- Older: show month + day + year
			text = pad(os.date("%b %d  %Y", mtime_secs))
		end
	else -- always show full timestamp
		-- show month + day + mtime + year
		text = pad(os.date("%b %e %H:%M  %Y", mtime_secs))
	end

	return colored_span(text, color)
end

-- Load config
local _load_config = ya.sync(function(_, opts)
	opts = opts or {}
	CFG.hour_threshold = opts.hour_threshold or DEFAULT.hour_threshold
	CFG.day_threshold = opts.day_threshold or DEFAULT.day_threshold
	CFG.color_hour = opts.color_hour or DEFAULT.color_hour
	CFG.color_day = opts.color_day or DEFAULT.color_day
	CFG.color_older = opts.color_older or DEFAULT.color_older
	CFG.yazi_age_format = opts.yazi_age_format or DEFAULT.yazi_age_format
	CFG.width = opts.width or DEFAULT.width
end)

-- Linemode: lsd_mtime (date only, colored)
function Linemode:lsd_mtime()
	local mtime = math.floor(self._file.cha.mtime or 0)
	return fmt_mtime_colored(mtime)
end

-- Linemode: lsd_size_mtime (size + colored date)
function Linemode:lsd_size_mtime()
	local mtime = math.floor(self._file.cha.mtime or 0)
	local size_s = string.format("%7s", fmt_size(self._file))
	local date_s = fmt_mtime_colored(mtime)

	-- Return Line composed of two spans (size and date)
	return ui.Line({
		ui.Span(size_s .. " "),
		date_s,
	})
end

-- Plugin entry point
return {
	setup = function(_, opts)
		_load_config(opts)
	end,
}
