eval (/opt/homebrew/bin/brew shellenv)

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Created by `pipx` on 2025-07-30 21:30:23
fish_add_path -aP /Users/rei/.local/bin

# run this last so that mise's paths take priority
mise activate fish | source


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/Users/rei/.opam/opam-init/init.fish' && source '/Users/rei/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
