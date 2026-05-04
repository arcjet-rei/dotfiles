#!/usr/bin/env bash
# Per-developer customizations applied at the end of setup.sh.
#
# Canonical location: ~/.local/bin/arcjet-dev-local-setup.sh (this file).
# The arcjet monorepo's dev/setup.local.sh (gitignored) is a RELATIVE
# symlink back to here. setup.sh inside OrbStack VMs follows the symlink
# through the /mnt/mac mount, which works because the link target
# traverses the mount (../../.../.local/bin/...) rather than an absolute
# host path that doesn't exist inside the VM. Create the link in a new
# checkout via:
#   cd arcjet/dev && ln -s ../../../../../.local/bin/arcjet-dev-local-setup.sh setup.local.sh
# (adjust the "../"s if your checkout is at a different depth — the
# current value assumes ~/Documents/projects/arcjet-code/arcjet).
#
# setup.sh exports MAC_HOME (the /mnt/mac/Users/<name> path to the host
# home) and SCRIPT_DIR (the arcjet/dev directory) before invoking us.
set -euo pipefail

if [[ -z ${MAC_HOME-} || ! -d ${MAC_HOME} ]]; then
	echo "  MAC_HOME not available, skipping local customizations"
	exit 0
fi

# Copy ccstatusline config from the host. ccstatusline reads its config
# from $XDG_CONFIG_HOME/ccstatusline (i.e. ~/.config/ccstatusline), which
# isn't covered by the ~/.claude / ~/.claude.json symlinks setup.sh wires
# up for core Claude Code state.
ccsrc="${MAC_HOME}/.config/ccstatusline"
ccdst="${HOME}/.config/ccstatusline"
if [[ -d ${ccsrc} ]]; then
	mkdir -p "${HOME}/.config"
	rm -rf "${ccdst}"
	cp -R "${ccsrc}" "${ccdst}"
	echo "  Copied ccstatusline config from host"
else
	echo "  No ~/.config/ccstatusline on host, skipping"
fi

# Personal tools kept out of dev/mise.toml so the shared base VM toolchain
# stays minimal for contributors who don't use them. delta is on PATH
# because my host ~/.gitconfig (inherited via [include]) sets it as
# core.pager.
#
# Write to ~/.config/mise/conf.d/personal.toml instead of `mise use -g`:
# dev/setup.sh now symlinks ~/.config/mise/config.toml at dev/mise.toml,
# so `mise use -g` would write through the symlink and stomp the shared
# toolchain config in the repo. mise auto-loads everything in
# ~/.config/mise/conf.d/.
#
# claude is intentionally NOT listed here — it's in dev/mise.toml as a
# shared team tool, and conf.d entries don't reliably override the
# global config.toml when both define the same tool (config.toml wins
# in cwd-local walks). Bump claude in dev/mise.toml directly when a new
# version is wanted.
echo "==> Installing personal tools via mise..."
mkdir -p "${HOME}/.config/mise/conf.d"
cat >"${HOME}/.config/mise/conf.d/personal.toml" <<'PERSONAL_MISE_EOF'
[tools]
bun = "1.3.12"
delta = "0.19.2"
fd = "10.2.0"
fzf = "0.56.3"
lazygit = "0.44.1"
neovim = "0.12.1"
ripgrep = "14.1.1"
PERSONAL_MISE_EOF
~/.local/bin/mise install

# LazyVim's lazy-lock.json comes along with the copy, pinning plugin
# versions to whatever the host has.
nvimsrc="${MAC_HOME}/.config/nvim"
nvimdst="${HOME}/.config/nvim"
if [[ -d ${nvimsrc} ]]; then
	mkdir -p "${HOME}/.config"
	rm -rf "${nvimdst}"
	cp -R "${nvimsrc}" "${nvimdst}"
	echo "  Copied nvim config from host"
elif [[ ! -d ${nvimdst} ]]; then
	mkdir -p "${HOME}/.config"
	git clone --depth 1 https://github.com/LazyVim/starter "${nvimdst}"
	rm -rf "${nvimdst}/.git"
	echo "  Cloned LazyVim starter into ~/.config/nvim"
else
	echo "  No ~/.config/nvim on host; keeping existing VM config"
fi

# Bootstrap LazyVim + Mason once; Lazy/Mason self-update on interactive
# launches, so a marker skips the slow sync on subsequent setup.sh runs.
#
# Two nvim invocations:
#
# Pass 1 runs Lazy! sync to install plugins and run build hooks. The
# nvim-treesitter LazyVim spec has a known race — its `build` and
# `config` functions both call ensure_treesitter_cli, which trips
# Mason's "Package is already installing" guard. The error is non-fatal
# (Lazy continues syncing the rest of the plugins, and Pass 2 cleanly
# retries the install) so we tolerate it with `|| true`.
#
# Pass 2 force-loads the plugins that lazy-trigger Mason installs on
# filetype/buffer events — LSP servers (mason-lspconfig), DAP adapters
# (mason-nvim-dap), formatters (conform), linters (nvim-lint). Those
# events never fire in headless mode, so without this the marker would
# be set against an empty toolchain. nvim-treesitter is intentionally
# absent from the load list: Pass 1's build hook already loaded it,
# and re-loading would re-trigger the build/config race.
#
# `mason_wait_lua` is the polling barrier between and after the passes.
# It blocks up to 15 min, returning only when no Mason package reports
# :is_installing(). Iteration uses get_all_package_names() rather than
# get_installed_packages() — the latter only returns already-installed
# packages, so first-time installs are invisible to the poll. Periodic
# print() output (every ~30s) shows what's still in flight; otherwise
# multi-minute installs (codelldb, java-debug-adapter) look like a
# hang.
nvim_marker="${HOME}/.cache/arcjet-dev/nvim-bootstrapped"
if [[ ! -f ${nvim_marker} ]] && command -v nvim >/dev/null 2>&1; then
	echo "==> Bootstrapping LazyVim + Mason (first run, can take 5-15min)..."

	# trunk-ignore(shellcheck/SC2016): single-quoted Lua expression — bash should not expand $-references
	mason_wait_lua='do local last = 0; vim.wait(900000, function() local ok, mr = pcall(require, "mason-registry"); if not ok then return true end; local installing = {}; for _, name in ipairs(mr.get_all_package_names()) do local pok, pkg = pcall(mr.get_package, name); if pok and pkg:is_installing() then table.insert(installing, name) end end; if #installing == 0 then return true end; if vim.uv.now() - last > 30000 then last = vim.uv.now(); print("[bootstrap] still installing: " .. #installing .. " packages (" .. table.concat(installing, ", ") .. ")") end; return false end, 2000) end'

	# Pass 1: install plugins + run build hooks. Tolerate the
	# nvim-treesitter build/config race (non-fatal; Pass 2 cleans up).
	nvim --headless \
		-c "Lazy! sync" \
		-c "lua vim.wait(5000)" \
		-c "lua ${mason_wait_lua}" \
		+qa </dev/null || true

	# Pass 2: queue and complete LSP/DAP/lint Mason installs.
	nvim --headless \
		-c "Lazy! load mason.nvim mason-lspconfig.nvim mason-nvim-dap.nvim conform.nvim nvim-lint" \
		-c "lua vim.wait(5000)" \
		-c "lua ${mason_wait_lua}" \
		+qa </dev/null

	mkdir -p "$(dirname "${nvim_marker}")"
	touch "${nvim_marker}"
fi

# Seed node_modules in this workspace's worktree so Trunk's @node linters
# (prettier@node, eslint@node) can resolve their binaries from
# ./node_modules/.bin. Without node_modules present, Trunk falls back to
# running `npm install prettier@node` against its own cache, which always
# fails — @node is Trunk syntax, not an npm dist-tag, so npm returns
# ETARGET and the pre-commit hook breaks.
#
# Each OrbStack VM is created by `dev create <name>`, which also creates
# a worktree at ~/Documents/arcjet-dev/<name>/arcjet. The VM hostname
# matches the workspace name, so we can derive the worktree path without
# the dev CLI needing to pass it explicitly.
workspace_name="$(hostname)"
worktree="${MAC_HOME}/Documents/arcjet-dev/${workspace_name}/arcjet"
if [[ -f "${worktree}/package.json" && ! -d "${worktree}/node_modules" ]]; then
	echo "==> Seeding node_modules in workspace worktree (~40s)..."
	(cd "${worktree}" && npm ci)
fi

# Alias g -> git for my shell habits. Appended to both rc files since
# setup.sh already writes prompt/mise-activation to bashrc and zshrc.
for rc in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
	if [[ -f ${rc} ]] && ! grep -q '^alias g=git$' "${rc}"; then
		printf '\n# Added by dev/setup.local.sh\nalias g=git\n' >>"${rc}"
		echo "  Added alias g=git to $(basename "${rc}")"
	fi
done

# fzf key bindings (Ctrl-T / Ctrl-R / Alt-C) + completion for bash. My
# host fish/zsh dotfiles handle this separately; bash needs an explicit
# `eval "$(fzf --bash)"`, available in fzf >= 0.48.
if [[ -f ${HOME}/.bashrc ]] && ! grep -q 'fzf --bash' "${HOME}/.bashrc"; then
	# shellcheck disable=SC2016 # Expressions in single quotes are intentional — they are written to .bashrc for later evaluation
	printf '\n# Added by dev/setup.local.sh\ncommand -v fzf >/dev/null && eval "$(fzf --bash)"\n' >>"${HOME}/.bashrc"
	echo "  Added fzf bash integration to .bashrc"
fi

echo "==> Verifying local installations..."
# trunk-ignore-begin(shellcheck/SC2312): subshell return values are fine here
echo "  bun:     $(bun --version 2>/dev/null || echo 'not found')"
echo "  delta:   $(delta --version 2>/dev/null | head -1 || echo 'not found')"
echo "  fd:      $(fd --version 2>/dev/null || echo 'not found')"
echo "  fzf:     $(fzf --version 2>/dev/null || echo 'not found')"
echo "  lazygit: $(lazygit --version 2>/dev/null | head -1 || echo 'not found')"
echo "  nvim:    $(nvim --version 2>/dev/null | head -1 || echo 'not found')"
echo "  rg:      $(rg --version 2>/dev/null | head -1 || echo 'not found')"
# trunk-ignore-end(shellcheck/SC2312)
