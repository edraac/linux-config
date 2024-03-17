if [[ -e ~/.bashrc.d/configure-prompt.sh ]]; then
    . ~/.bashrc.d/configure-prompt.sh
    PROMPT_COLOR="${PROMPT_COLOR:-32}"
    PROMPT_USERHOST="${PROMPT_USERHOST:-\u@\h}"
    PROMPT_SEPARATOR="${PROMPT_SEPARATOR:-:}"
    PROMPT_DIRECTORY="${PROMPT_DIRECTORY:-\w}"
    colorpre='\[\e['
    colorsuf='m\]'
    colorreset="${colorpre}0${colorsuf}"
    PS1='${PROMPT_START@P}'"${colorpre}"'${PROMPT_COLOR}'"${colorsuf}"'${PROMPT_USERHOST@P}'"${colorreset}"'${PROMPT_SEPARATOR@P}'"${colorpre}"'${PROMPT_DIR_COLOR:-${PROMPT_COLOR}}'"${colorsuf}"'${PROMPT_DIRECTORY@P}'"${colorreset}"'${PROMPT_END@P}\$'"${colorreset} "
fi