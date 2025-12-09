function upgrade-everything --description 'Run all the update commands that can be run without intervention'
    date
    topgrade
    nvim --headless "+Lazy! sync" +qa
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
