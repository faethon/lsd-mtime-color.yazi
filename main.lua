-- # ls-deluxe-colors.yazi
--
-- A [Yazi](https://github.com/sxyazi/yazi) linemode plugin that colors file
-- modification times and file sizes similar to **LSD (LSDeluxe)**
--
-- Coloring of timestamp based on age:
--
--    < 1 hour ago  -->  bright green
--    < 1 day ago   -->  green
--    < 30 days ago -->  teal
--    older         -->  dark teal
--
-- Coloring of file size based on size:
--
--    0 B           --> gray
--    < 1KB         --> light yellow
--    < 1MB         --> yellow
--    < 100MB       --> orange
--    larger        --> dark orange
--
-- See README for installation and configuration

-- Default configuration
local DEFAULT = {
	hour_threshold = 3600, -- 1 hour in seconds
	day_threshold = 86400, -- 1 day  in seconds
	month_threshold = 2592000, -- 30 days in seconds
	color_hour = "#00d700",
	color_day = "#00d787",
	color_month = "#00af87",
	color_older = "#00875f",
	size_small_threshold = 1024, -- < 1 KB
	size_medium_threshold = 1024 * 1024, -- < 1 MB
	size_large_threshold = 100 * 1024 * 1024, -- < 100 MB
	color_size_none = "#6c6c6c",
	color_size_small = "#ffffaf",
	color_size_medium = "#ffd787",
	color_size_large = "#ffaf5f",
	color_size_huge = "#ff8700",
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

-- classify based on size
local function classify_size(sz)
	if not sz or sz == 0 then
		return "none"
	elseif sz <= CFG.size_small_threshold then
		return "small"
	elseif sz <= CFG.size_medium_threshold then
		return "medium"
	elseif sz <= CFG.size_large_threshold then
		return "large"
	else
		return "huge"
	end
end

-- select color bracket for size
local function size_color(class)
	if class == "none" then
		return CFG.color_size_none
	elseif class == "small" then
		return CFG.color_size_small
	elseif class == "medium" then
		return CFG.color_size_medium
	elseif class == "large" then
		return CFG.color_size_large
	else
		return CFG.color_size_huge
	end
end

-- select color bracket for age
local function age_color(age)
	if age < CFG.hour_threshold then
		return CFG.color_hour
	elseif age < CFG.day_threshold then
		return CFG.color_day
	elseif age < CFG.month_threshold then
		return CFG.color_month
	else
		return CFG.color_older
	end
end

-- create timestamp text
local function age_text(mtime_secs)
	if CFG.yazi_age_format then
		-- Format string (same smart logic as linemode-plus / yazi built-in)
		local today = os.date("*t")
		local fdate = os.date("*t", mtime_secs)

		if fdate.year == today.year and fdate.month == today.month and fdate.day == today.day then
			-- Today: show time only
			return pad(os.date("%H:%M", mtime_secs))
		elseif fdate.year == today.year then
			-- This year: show month + day + time
			return pad(os.date("%b %d %H:%M", mtime_secs))
		else
			-- Older: show month + day + year
			return pad(os.date("%b %d  %Y", mtime_secs))
		end
	else -- always show full timestamp
		-- show month + day + mtime + year
		return pad(os.date("%b %e %H:%M  %Y", mtime_secs))
	end
end

-- Format human-readable file size and pick matching color
local function fmt_size_colored(file)
	local sz = file:size()
	if not sz then
		return ui.Span("  -")
	end

	local class = classify_size(sz)
	local color = size_color(class)
	local text = string.format("%7s", ya.readable_size(sz))

	return colored_span(text, color)
end

-- Format mtime timestamp and pick mathcing color
local function fmt_mtime_colored(mtime_secs)
	local age = os.time() - mtime_secs
	if mtime_secs == 0 then
		return ui.Span(pad("")) -- empty padding
	end

	local color = age_color(age)
	local text = age_text(mtime_secs)

	return colored_span(text, color)
end

-- Load config
local _load_config = ya.sync(function(_, opts)
	opts = opts or {}
	CFG.hour_threshold = opts.hour_threshold or DEFAULT.hour_threshold
	CFG.day_threshold = opts.day_threshold or DEFAULT.day_threshold
	CFG.month_threshold = opts.month_threshold or DEFAULT.month_threshold
	CFG.color_hour = opts.color_hour or DEFAULT.color_hour
	CFG.color_day = opts.color_day or DEFAULT.color_day
	CFG.color_month = opts.color_month or DEFAULT.color_month
	CFG.color_older = opts.color_older or DEFAULT.color_older
	CFG.size_small_threshold = opts.size_small_threshold or DEFAULT.size_small_threshold
	CFG.size_medium_threshold = opts.size_medium_threshold or DEFAULT.size_medium_threshold
	CFG.size_large_threshold = opts.size_large_threshold or DEFAULT.size_large_threshold
	CFG.color_size_none = opts.color_size_none or DEFAULT.color_size_none
	CFG.color_size_small = opts.color_size_small or DEFAULT.color_size_small
	CFG.color_size_medium = opts.color_size_medium or DEFAULT.color_size_medium
	CFG.color_size_large = opts.color_size_large or DEFAULT.color_size_large
	CFG.color_size_huge = opts.color_size_huge or DEFAULT.color_size_huge
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
	local size_span = fmt_size_colored(self._file)
	local date_s = fmt_mtime_colored(mtime)

	-- Return Line composed of two spans (size and date)
	return ui.Line({
		size_span,
		ui.Span(" "),
		date_s,
	})
end

-- Plugin entry point
return {
	setup = function(_, opts)
		_load_config(opts)
	end,
}
