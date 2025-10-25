eval (/opt/homebrew/bin/brew shellenv)

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Created by `pipx` on 2025-07-30 21:30:23
set PATH $PATH /Users/rei/.local/bin

# run this last so that mise's paths take priority
mise activate fish | source
