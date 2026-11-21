-- Restore workspace layouts saved by codeswot-hyprland-workspace-layout-toggle.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local layouts_dir = paths.state_home .. "/codeswot/workspace-layouts"

require_all.files(layouts_dir, "omarchy.workspace-layouts", { reload = true })
