_dx.nix() {
    local cur prev
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    case "$prev" in
    switch | update | build)
        return 0
        ;;
    esac

    COMPREPLY=($(compgen -W "switch update build help" -- "$cur"))
}

complete -F _dx.nix dx.nix
