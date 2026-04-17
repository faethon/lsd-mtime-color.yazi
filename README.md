# lsd-mtime-color.yazi

A [Yazi](https://github.com/sxyazi/yazi) linemode plugin that colours file
modification times and file sizes similar to **LSD (LSDeluxe)**

Coloring of timestamp based on age:
```
   < 1 hour ago  -->  bright green
   < 1 day ago   -->  green
   < 30 days ago -->  teal
   older         -->  dark teal
```

Coloring of file size based on size:
```
   0 B           --> gray
   < 1KB         --> light yellow
   < 1MB         --> yellow
   < 100MB       --> orange
   larger        --> dark orange
```

The colours can be configured, as well as the thresholds for age and size.

---

## Installation

**Via Yazi package manager**:

```sh
ya pkg add faethon/lsd-mtime-color
```

**Manually:**

```sh
mkdir -p ~/.config/yazi/plugins/lsd-mtime-color.yazi
cp main.lua ~/.config/yazi/plugins/lsd-mtime-color.yazi/main.lua
```

---

## Setup

Add to `~/.config/yazi/init.lua`:

```lua
require("lsd-mtime-color"):setup()
```

Or with custom settings, change the values accordingly (defaults are shown).
You only have to include those values you would like to change.

```lua
require("lsd-mtime-color"):setup({
  hour_threshold  = 3600,              -- seconds in an hour
  day_threshold   = 86400,             -- seconds in a day
  month_threshold = 2592000,           -- seconds in 30 days
  color_hour      = "#00d700",         -- colour for < 1 hour
  color_day       = "#00d787",         -- colour for < 1 day
  color_month     = "#00af87",         -- colour for < 30 days
  color_older     = "#00875f",         -- colour for older
  small_size      = 1024,              -- threshold for small  (1 KB)
  medium_size     = 1024 * 1024,       -- threshold for medium  (1 MB)
  large_size      = 100 * 1024 * 1024, -- threshold for large  (100 MB)
  color_none      = "#6c6c6c",         -- colour for size 0
  color_small     = "#ffffaf",         -- colour for size small
  color_medium    = "#ffd787",         -- colour for size medium 
  color_large     = "#ffaf5f",         -- colour for size large
  color_huge      = "#ff8700",         -- colour for size huge
  yazi_age_format = false,             -- use yazi time format
  width           = 12                 -- width to use for padding timestamps
})
```

---

## Enable the linemode

In `~/.config/yazi/yazi.toml`:

```toml
[mgr]
# Date only, coloured:
linemode = "lsd_mtime"
```

Or size + coloured date

```toml
# Size + coloured date:
linemode = "lsd_size_mtime"
```

Bind keys to toggle between both modes in `~/.config/yazi/keymap.toml`:

```toml
[mgr]
prepend_keymap = [
    # linemode-lsd plugin
    { on = [ "m", "l" ], run = "linemode lsd_size_mtime", desc = "Linemode: lsd size+mtime" },
    { on = [ "m", "k" ], run = "linemode lsd_mtime", desc = "Linemode: lsd mtime" },

    # Sorting does not override linemode (from recommendeds by barbanevosa/linemode-plus)
    { on = [ ",", "m" ], run = [ "sort mtime --reverse=no" ], desc = "Sort by modified time" },
    { on = [ ",", "M" ], run = [ "sort mtime --reverse=yes" ], desc = "Sort by modified time (reverse)" },
    { on = [ ",", "b" ], run = [ "sort btime --reverse=no" ], desc = "Sort by birth time" },
    { on = [ ",", "B" ], run = [ "sort btime --reverse=yes" ], desc = "Sort by birth time (reverse)" },
    { on = [ ",", "s" ], run = [ "sort size --reverse=no" ], desc = "Sort by size" },
    { on = [ ",", "S" ], run = [ "sort size --reverse=yes" ], desc = "Sort by size (reverse)" },
]
```

## License

MIT
