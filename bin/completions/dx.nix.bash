_dx.nix() {
    local cur prev
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    case "$prev" in
    switch | build | active | eval | update | help)
        return 0
        ;;
    esac

    COMPREPLY=($(compgen -W "switch build activate eval update help" -- "$cur"))
}

complete -F _dx.nix dx.nix
