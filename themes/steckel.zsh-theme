ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔%{$reset_color%}"

function git_branch() {
  echo "${ref#refs/heads/}"
}

function git_status() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$(git_branch) $(parse_git_dirty) $(git_prompt_short_sha)"
}

PROMPT='%c > '

RPS1='$(git_status)'