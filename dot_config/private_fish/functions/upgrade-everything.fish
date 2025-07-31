function upgrade-everything --description 'Run all the update commands that can be run without intervention'
    date
    nvim --headless "+Lazy! sync" +qa
    and brew upgrade
    and rustup update
    and if begin
            asdf latest --all
        end
        echo "All asdf-managed languages up to date."
    else
        echo -e "\033[93;1mSome asdf-managed languages need updating.\033[0m"
    end
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
