if ! which git &> /dev/null; then
  return
fi

# TODO: add completion script from https://github.com/git/git/tree/master/contrib/completion

alias g="git"

# git-specific aliases
__define_git_completion () {
  eval "
  _git_$2_shortcut () {
  COMP_LINE=\"git $2\${COMP_LINE#$1}\"
  let COMP_POINT+=$((4+${#2}-${#1}))
  COMP_WORDS=(git $2 \"\${COMP_WORDS[@]:1}\")
  let COMP_CWORD+=1

  local cur words cword prev
  _get_comp_words_by_ref -n =: cur words cword prev
  _git_$2
}
"
}

__git_shortcut () {
  type _git_$2_shortcut &>/dev/null || __define_git_completion $1 $2
  alias $1="git $2 $3"
  complete -o default -o nospace -F _git_$2_shortcut $1
}

# Alias and set up tab completion
__git_shortcut  ga    add
__git_shortcut  gb    branch
__git_shortcut  gbd   branch -D
__git_shortcut  gco   checkout
__git_shortcut  gd    diff
__git_shortcut  gf    fetch
__git_shortcut  gl    log
__git_shortcut  glp   log -p
__git_shortcut  gls   log --stat

# No completion for these
alias gp='git push'
alias gpf='git push --force'
alias gs='git status'
alias gc='git commit'
alias gpr='git pull --rebase'
alias gin='git fetch; git whatchanged ..origin'
alias gout='git fetch; git whatchanged origin..'
alias gpsu='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gfa='git fetch --all'
alias gcom='git checkout master'
alias gdm='git diff master'
alias gpom='git pull origin master'
alias gms='git merge --squash'
alias gcob='git checkout -B'
alias gds='git diff --staged'
alias gss='git stash save'
alias gsa='git stash apply'
alias grm='git rebase master'
alias gr='git rebase'
alias gri='git rebase -i'
alias gca='git commit --amend'
alias gaa='git add .'
alias gsh='git show HEAD'
alias grhh='git reset --hard HEAD'
alias grsh='git reset --soft HEAD~1'
alias gpoh='git push origin HEAD'
alias gpfoh='git push --force origin HEAD'
alias gmm='git merge master'
