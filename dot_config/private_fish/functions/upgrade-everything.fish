function upgrade-everything --description 'Run all the update commands that can be run without intervention'
    date
    nvim --headless "+Lazy! sync" +qa
    and brew upgrade
    and rustup update
    and mise outdated --bump
    and softwareupdate -ia
    and mas upgrade
    and if begin
            chezmoi verify
        end
        echo "No changes to tracked dotfiles."
    else
        echo "Chezmoi status:"
        chezmoi diff --reverse
        chezmoi status
    end
    date
end
