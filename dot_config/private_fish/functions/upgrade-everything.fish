function upgrade-everything --description 'Run all the update commands that can be run without intervention'
    date
    and brew upgrade
    and mas upgrade
    and nvim --headless "+Lazy! sync" +qa
    and rustup update
    and if begin
            asdf latest --all
        end
        echo "All asdf-managed languages up to date."
    else
        echo "Some asdf-managed languages need updating."
    end
    and softwareupdate -ia
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
