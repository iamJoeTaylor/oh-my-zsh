###
#   CONFIGURATION STUFF YOU CAN EDIT
###

# SET YOUR ALIAS TO SWITCH BETWEEN SUPERUSER MODE AND NORMAL MODE:
alias ~="super_user_toggle"

# THE THEME VARIABLES FOR COLOR AND ICONOGRAPHY
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}●"
ZSH_THEME_GIT_PROMPT_SIMPLE_CHANGED="%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}●"
ZSH_THEME_GIT_PROMPT_SIMPLE_STAGED="%{$fg[green]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}⚑"
ZSH_THEME_GIT_PROMPT_REMOTE_AHEAD="%{$fg[green]%}↑"
ZSH_THEME_GIT_PROMPT_REMOTE_BEHIND="%{$fg[red]%}↓"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}…"


ZSH_THEME_SVN_PROMPT_DIRTY=$ZSH_THEME_GIT_PROMPT_DIRTY
ZSH_THEME_SVN_PROMPT_CLEAN=$ZSH_THEME_GIT_PROMPT_CLEAN
ZSH_THEME_SVN_PROMPT_ADDED=$ZSH_THEME_GIT_PROMPT_STAGED
ZSH_THEME_SVN_PROMPT_MODIFIED=$ZSH_THEME_GIT_PROMPT_STAGED
ZSH_THEME_SVN_PROMPT_DELETED=$ZSH_THEME_GIT_PROMPT_REMOTE_BEHIND
ZSH_THEME_SVN_PROMPT_UNTRACKED=$ZSH_THEME_GIT_PROMPT_UNTRACKED
ZSH_THEME_SVN_PROMPT_CONFLICTED=$ZSH_THEME_GIT_PROMPT_CONFLICTS
###
#   LESS CONFIGURABLE STUFF YOU PROBABLY SHOULD'NT EDIT
###

# POINT ME TO WHERE GITSTATUS.PY IS... IT SHOULD BE IN THE .OH-MY-ZSH/LIB
export __GIT_PROMPT_DIR=~/.oh-my-zsh/lib

# ALLOW FOR FUNCTIONS IN THE PROMPT.
setopt PROMPT_SUBST

# THE ZSH HOOKS THAT WILL KEEP OUR GIT VARS UP TO DATE
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd_update_git_vars
add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

function preexec_update_git_vars() {
  case "$2" in
    git*)
    __EXECUTED_GIT_COMMAND=1
    ;;
  esac
}

function precmd_update_git_vars() {
  if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
    update_current_git_vars
    unset __EXECUTED_GIT_COMMAND
  fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

# SVN FUNCTIONS
function in_svn() {
		local OUTPUT="`svn info 2>&1 | grep 'not a working copy'`"
    if [ -z "$OUTPUT" ]; then
        echo 1
    fi
}

function svn_get_repo_name {
    if [ $(in_svn) ]; then
        svn info | sed -n 's/Repository\ Root:\ .*\///p' | read SVN_ROOT

        svn info | sed -n "s/URL:\ .*$SVN_ROOT\///p" | sed "s/\/.*$//"
    fi
}

function svn_get_rev_nr {
    if [ $(in_svn) ]; then
        svn info 2> /dev/null | sed -n s/Revision:\ //p
    fi
}

function svn_dirty_choose {
    if [ $(in_svn) ]; then
        s=$(svn status|grep -E '^\s*[ACDIM!?L]' 2>/dev/null)
        if [ $s ]; then
            echo $1
        else
            echo $2
        fi
    fi
}

function svn_dirty {
    svn_dirty_choose $ZSH_THEME_SVN_PROMPT_DIRTY $ZSH_THEME_SVN_PROMPT_CLEAN
}

svn_prompt_status() {
  INDEX=$(svn status 2> /dev/null) || return
  STATUS=""
  if $(echo "$INDEX" | grep '^? '  &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^? '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_UNTRACKED$TEMP$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^A '|wc -l|sed -e 's/[ ]*//g')
		STATUS="$ZSH_THEME_SVN_PROMPT_ADDED$TEMP$STATUS"
  elif $(echo "$INDEX" | grep '^AM  ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^AM '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_ADDED$TEMP$STATUS"
  fi
  if $(echo "$INDEX" | grep '^M ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^M '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_MODIFIED$TEMP$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^AM '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_MODIFIED$TEMP$STATUS"
  fi
  if $(echo "$INDEX" | grep '^C  ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^C '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_CONFLICTED$TEMP$STATUS"
  elif $(echo "$INDEX" | grep '^AC ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^AC '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_CONFLICTED$TEMP$STATUS"
  fi
  if $(echo "$INDEX" | grep '^D ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^D '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_DELETED$TEMP$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
		TEMP=$(echo "$INDEX" | grep '^AD '|wc -l|sed -e 's/[ ]*//g')
    STATUS="$ZSH_THEME_SVN_PROMPT_DELETED$TEMP$STATUS"
  fi
  echo $STATUS
}


# LETS GET SOME BASH VARS OUT OF THAT PYTHON LIB FILE
function update_current_git_vars() {
  unset __CURRENT_GIT_STATUS
  local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
  _GIT_STATUS=`python ${gitstatus}`
  __CURRENT_GIT_STATUS=("${(@f)_GIT_STATUS}")
  GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
  GIT_REMOTE_AHEAD=$__CURRENT_GIT_STATUS[2]
  GIT_REMOTE_BEHIND=$__CURRENT_GIT_STATUS[3]
  GIT_STAGED=$__CURRENT_GIT_STATUS[4]
  GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
  GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
  GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
  GIT_CLEAN=$__CURRENT_GIT_STATUS[8]
}

function git_remote_status() {
  STATUS=""
  if [ -n "$GIT_REMOTE_AHEAD" -o -n "$GIT_REMOTE_BEHIND" ]; then
    if [ -n "$GIT_REMOTE_AHEAD" -a "$GIT_REMOTE_AHEAD" != "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE_AHEAD$GIT_REMOTE_AHEAD"
    fi
    if [ -n "$GIT_REMOTE_BEHIND" -a "$GIT_REMOTE_BEHIND" != "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE_BEHIND$GIT_REMOTE_BEHIND"
    fi
  fi
  if [ "$STATUS" != "" ]; then
    echo "[$STATUS%{${reset_color}%}]"
  fi
}

function git_dirt() {
  if [ "$GIT_UNTRACKED" -ne "0" ]; then
    STATUS="$ZSH_THEME_GIT_PROMPT_SIMPLE_CHANGED%{${reset_color}%}"
  elif [ "$GIT_STAGED" -ne "0" ]; then
    STATUS="$ZSH_THEME_GIT_PROMPT_SIMPLE_STAGED%{${reset_color}%}"
  elif [ "$GIT_CHANGED" -ne "0" ]; then
    STATUS="$ZSH_THEME_GIT_PROMPT_SIMPLE_CHANGED%{${reset_color}%}"
  elif [ "$GIT_CONFLICTS" -ne "0" ]; then
    STATUS="$ZSH_THEME_GIT_PROMPT_CONFLICTS%{${reset_color}%}"
  else
    STATUS="$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
  echo "$STATUS"
} 

function git_advanced_dirt() {
  STATUS=""
  if [ "$GIT_STAGED" -ne "0" ]; then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED%{${reset_color}%}"
  fi
  if [ "$GIT_CHANGED" -ne "0" ]; then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED%{${reset_color}%}"
  fi
  if [ "$GIT_UNTRACKED" -ne "0" ]; then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED%{${reset_color}%}"
  fi
  if [ "$GIT_CLEAN" -eq "1" ]; then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
  echo "$STATUS"
}

function git_conflicts() {
  if [ "$GIT_CONFLICTS" -ne "0" ]; then
    echo "$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%{${reset_color}%}"
  fi
}

# THE ON/OFF SWITCH FOR "SUPERUSER" MODE.
SUPERUSER=false
function super_user_toggle() {
  if $SUPERUSER; then
    SUPERUSER=false
  else
    SUPERUSER=true
  fi
}

function right_prompt() {
  if $SUPERUSER; then
		if [ $(in_svn) ]; then
    	echo "$(svn_get_repo_name) $(svn_prompt_status) $(svn_dirty) $(svn_get_rev_nr)"
		else
			ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    	echo "$(git_conflicts) $GIT_BRANCH$(git_remote_status) $(git_advanced_dirt) $(git_prompt_short_sha)"
		fi
  else
		if [ $(in_svn) ]; then
    	echo "$(svn_get_repo_name) $(svn_dirty) $(svn_get_rev_nr)"
		else
			ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    	echo "$GIT_BRANCH $(git_dirt) $(git_prompt_short_sha)"
		fi
  fi
}

# OUR PROMPTS!
PROMPT='%c > '
RPS1='$(right_prompt)'