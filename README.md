# lsd-mtime-color.yazi

A [Yazi](https://github.com/sxyazi/yazi) linemode plugin that colours file
modification times exactly like **LSD (LSDeluxe)**

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

Or with custom options

```lua
require("lsd-mtime-color"):setup({
  hour_threshold  = 3600,       -- seconds in an hour
  day_threshold   = 86400,      -- seconds in a day
  color_hour      = "#00d700",  -- colour for < 1 hour
  color_day       = "#00d787",  -- colour for < 1 day
  color_older     = "#00af87",  -- colour for older files
  yazi_age_format = false,     -- show distinct detailed timestamp based on age
  width           = 12                   -- width to use for padding timestamps
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
    { on = [ "m", "l" ], run = "linemode lsd_size_mtime",
      desc = "Linemode: lsd size+mtime" },
    { on = [ "m", "k" ], run = "linemode lsd_mtime",
      desc = "Linemode: lsd mtime" },

    # Sorting does not override linemode (recommended by barbanevosa/linemode-plus)
    { on = [ ",", "m" ], run = [ "sort mtime --reverse=no" ],
      desc = "Sort by modified time" },
    { on = [ ",", "M" ], run = [ "sort mtime --reverse=yes" ],
      desc = "Sort by modified time (reverse)" },
    { on = [ ",", "b" ], run = [ "sort btime --reverse=no" ],
      desc = "Sort by birth time" },
    { on = [ ",", "B" ], run = [ "sort btime --reverse=yes" ],
      desc = "Sort by birth time (reverse)" },
    { on = [ ",", "s" ], run = [ "sort size --reverse=no" ],
      desc = "Sort by size" },
    { on = [ ",", "S" ], run = [ "sort size --reverse=yes" ],
      desc = "Sort by size (reverse)" },
]
```

## License

MIT
