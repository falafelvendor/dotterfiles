--https://www.gnome-look.org/p/2305696--
------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.25,
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.config({
    layerrule = {
        { blur = "wofi" },
        { ignorezero = "wofi" },
    },
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd("sleep 1 && /usr/lib/xdg-desktop-portal --replace")
    hl.exec_cmd("date '+[HYPREntry] %F %T' >> ~/.hypr-timestamp.log")
    hl.exec_cmd("systemctl enable NetworkManager.service")
    hl.exec_cmd("nmcli connection up Sahnun")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("mako")
    hl.exec_cmd("mount /dev/sda1 /mnt/HDD")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww img ~/.config/hypr/wallpapers/Wallpaper7.jpg --transition-type fade --transition-duration 2") 
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme BreezeX-RosePine-Linux")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
    hl.exec_cmd("nbfc start")
    hl.exec_cmd("waybar")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("[workspace 2 silent] firefox")
    hl.exec_cmd("sh -c 'sleep 1 && hyprsunset'")
    hl.exec_cmd("[workspace 5 silent] /home/faraz/Applications/Winboat.AppImage")
---hl.exec_cmd(terminal)
end)

hl.on("config.reloaded", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- FORCE HYPRLAND TO BOOT AND RENDER ON NVIDIA
--hl.env("AQ_DRM_DEVICES",      "/dev/dri/card1:/dev/dri/card2")




hl.env("HYPRCURSOR_SIZE",     "24")
hl.env("HYPRCURSOR_THEME",    "rose-pine-hyprcursor")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("MOZ_ENABLE_WAYLAND",  "1")
hl.env("GDK_BACKEND",         "wayland,x11,*")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 2.5,
        gaps_out = 7,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgb(003C43)", "rgb(487d78)"}, angle = 60 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 1}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4, bezier = "default",  style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "default" })

hl.config({
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,

},
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us, ara",
        kb_options = "grp:win_space_toggle",
        kb_variant = "",
        kb_model   = "",
        kb_rules   = "",

        force_no_accel = true,
        follow_mouse   = 1,
        sensitivity    = -0.8,

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Screenshots
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Hyprshot"))
hl.bind("PRINT",                hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Hyprshot"))
hl.bind("SHIFT + PRINT",        hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Hyprshot"))

-- Apps
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("loginctl terminate-session $XDG_SESSION_ID"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/.config/wofi/hyprsunset.sh"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- System
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("poweroff"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("reboot"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("loginctl terminate-session $XDG_SESSION_ID"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("/home/$USER/.config/hypr/wallpapers.sh"))

-- Notifications
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd("makoctl mode -t dnd"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("makoctl dismiss --all"))

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))

-- Special workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Media
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

require("windowrules")
