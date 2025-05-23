# Based on the agnoster theme with a few modification


### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  (( $+commands[timeout] )) || return  # Ensure the 'timeout' command exists

  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path git_output

  if $(timeout 0.2 git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(timeout 0.2 git rev-parse --git-dir 2>/dev/null)

    # Get dirty status with timeout
    git_output=$(timeout 0.2 git status --porcelain 2>/dev/null)
    if [[ $? -eq 0 ]]; then
      if [[ -n "$git_output" ]]; then
        dirty="●" # Indicate dirty in some way
      fi
    fi

    # Get branch/HEAD with timeout
    git_output=$(timeout 0.2 git symbolic-ref HEAD 2> /dev/null)
    if [[ $? -eq 0 && -n "$git_output" ]]; then
      ref=$(echo "$git_output" | sed 's#refs/heads/##')
    else
      git_output=$(timeout 0.2 git rev-parse --short HEAD 2> /dev/null)
      if [[ $? -eq 0 && -n "$git_output" ]]; then
        ref="➦ $git_output"
      fi
    fi

    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green $CURRENT_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    echo -n "${ref:-}${dirty:-}${mode:-}"
  fi
}

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=bzr status | head -n1 | grep "modified" | wc -m
        status_all=bzr status | head -n1 | wc -m
        revision=bzr log | head -n2 | tail -n1 | sed 's/^revno: //'
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment yellow black
            echo -n "bzr@"$revision "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment yellow black
                echo -n "bzr@"$revision

            else
                prompt_segment green black
                echo -n "bzr@"$revision
            fi
        fi
    fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green $CURRENT_FG
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if hg st | grep -q "^\?"; then
        prompt_segment red black
        st='±'
      elif hg st | grep -q "^[MA]"; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green $CURRENT_FG
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  if [[ $(hostname) == *"dev"* ]]; then
    prompt_segment red $CURRENT_FG '%m'
  fi
  prompt_segment blue $CURRENT_FG '%~'
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(basename $virtualenv_path)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  symbols+="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$reset_color%}"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}
## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}

PROMPT='$(build_prompt)'

# Configure the right prompt for interactive shells
if [[ -n "$PS1" ]]; then
  PS1="$PROMPT"
fi
