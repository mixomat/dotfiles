#!/bin/bash

# this symlinks all the dotfiles to ~/

# this is safe to run multiple times and will prompt you about anything unclear

# inspired by alrra's nice work:
#   https://raw.githubusercontent.com/alrra/dotfiles/master/os/create_symbolic_links.sh

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare symlinkDirectory="$HOME"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
create_symlinks() {

    declare -a FILES_TO_SYMLINK=(
        "shell/zshenv"
        "shell/zshrc"

        "git/gitconfig"
        "git/gitignore"

        "vim/vimrc"
        "vim/ideavimrc"

        "tmux/tmux.conf"
    )

    local i=""
    local sourcePath=""
    local sourceFile=""
    local targetFile=""
    local skipQuestions=false

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    for i in "${FILES_TO_SYMLINK[@]}"; do

        sourcePath="$(cd .. && pwd)/$i"
        sourceFile="$(get_env_file $sourcePath)"
        targetFile="$symlinkDirectory/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ ! -e "$targetFile" ] || $skipQuestions; then

            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"

        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else


            ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
            if answer_is_yes; then

                rm -rf "$targetFile"

                execute \
                    "ln -fs $sourceFile $targetFile" \
                    "$targetFile → $sourceFile"

            else
                print_error "$targetFile → $sourceFile"
            fi

        fi

    done

}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n • Create symbolic links\n\n"
    create_symlinks
}

main
