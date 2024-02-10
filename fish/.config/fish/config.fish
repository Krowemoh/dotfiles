if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g -x MOZ_ENABLE_WAYLAND 1
    set -g -x WLR_NO_HARDWARE_CURSORS 1
    set PATH $PATH ~/.cargo/bin
    set PATH $PATH ~/bin

    alias b="cd ~/bp"
    alias sw="sway --unsupported-gpu"
    alias sx="startx"
    alias sx="sway --unsupported-gpu"

    if test -z "$DISPLAY" -a (tty) = "/dev/tty1"
        exec sway --unsupported-gpu
    end
end
