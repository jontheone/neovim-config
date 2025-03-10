local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.default_prog = {"wsl"}
config.colors = {
    foreground = 'silver',
    background = '#171717',
    cursor_bg = "white",
    cursor_border = 'white'
}
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.780
config.text_background_opacity = 1.0
config.font = wezterm.font("IntoneMono Nerd Font Mono", {weight="Bold", stretch="Normal", style="Normal"})
config.hide_tab_bar_if_only_one_tab = true

-- remaps
config.keys = {
    {key="x", mods="ALT|SHIFT", action=wezterm.action.CloseCurrentPane{confirm=true}},
    {key='+', mods="ALT|SHIFT", action=wezterm.action.SplitPane{direction='Right',size={Percent=50}}},
    {key='_', mods="ALT|SHIFT", action=wezterm.action.SplitPane{direction='Down',size={Percent=50}}},
    {key='H', mods="ALT|SHIFT|CTRL", action=wezterm.action.AdjustPaneSize{'Left', 7}},
    {key='L', mods="ALT|SHIFT|CTRL", action=wezterm.action.AdjustPaneSize{'Right', 7}},
    {key='J', mods="ALT|SHIFT|CTRL", action=wezterm.action.AdjustPaneSize{'Down', 3}},
    {key='K', mods="ALT|SHIFT|CTRL", action=wezterm.action.AdjustPaneSize{'Up', 3}},
    {key='Backspace', mods="CTRL", action=wezterm.action.SendString('\x17')},
    {key='H', mods="SHIFT|CTRL", action=wezterm.action.ActivatePaneDirection 'Left'},
    {key='L', mods="SHIFT|CTRL", action=wezterm.action.ActivatePaneDirection 'Right'},
    {key='J', mods="SHIFT|CTRL", action=wezterm.action.ActivatePaneDirection 'Down'},
    {key='K', mods="SHIFT|CTRL", action=wezterm.action.ActivatePaneDirection 'Up'},
}

return config

