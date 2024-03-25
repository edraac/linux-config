function configure_prompt {
    local colorpre='\[\e['
    local colorsuf='m\]'
    local NORMAL='0;'
    local BOLD='1;'
    local GREEN='32'
    local BLUE='34'
    local RED='31'
    local YELLOW='1;33'
    local DARK_GRAY='90'
    local CYAN='36'
    local VIOLET='35'
    local MAGENTA='35'
    local WHITE='39'
    local LIGHT_GRAY='37'
    local LIGHT_BLUE='94'

    unset git_prompt
    if [[ "$(type __git_ps1 2>&1 | head -n 1)" =~ "not found" ]] &&
        [[ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]]; then
        . /usr/share/git-core/contrib/completion/git-prompt.sh
    fi
    if [[ ! "$(type __git_ps1 2>&1 | head -n 1)" =~ "not found" ]]; then
        export GIT_PS1_SHOWDIRTYSTATE=true
        export GIT_PS1_SHOWSTASHSTATE=true
        export GIT_PS1_SHOWUNTRACKEDFILES=true
        export GIT_PS1_SHOWUPSTREAM='auto'
        export GIT_PS1_HIDE_IF_PWD_IGNORED=true
        unset GIT_PS1_SHOWCOLORHINTS
        __repo_state=$(__git_ps1)
        if [[ "${__repo_state}" =~ "*" ]]; then    # repository is dirty
            __git_prompt_color="${colorpre}${NORMAL}${RED}${colorsuf}"
        elif [[ "${__repo_state}" =~ "$" ]]; then  # there are stashed changes
            __git_prompt_color="${colorpre}${NORMAL}${YELLOW}${colorsuf}"
        elif [[ "${__repo_state}" =~ "%" ]]; then  # there are untracked files
            __git_prompt_color="${colorpre}${NORMAL}${DARK_GRAY}${colorsuf}"
        elif [[ "${__repo_state}" =~ "+" ]]; then  # there are staged files
            __git_prompt_color="${colorpre}${NORMAL}${CYAN}${colorsuf}"
        else                                       # default
            __git_prompt_color="${colorpre}${NORMAL}${GREEN}${colorsuf}"
        fi
        __git_prompt=$__git_prompt_color$__repo_state
    fi

    export PROMPT_COLOR="${BOLD}${GREEN}"
    export PROMPT_DIR_COLOR="${BOLD}${LIGHT_BLUE}"
    export PROMPT_END="${__git_prompt}${colorpre}${BOLD}${VIOLET}${colorsuf}\n"
}

export PROMPT_COMMAND=configure_prompt
