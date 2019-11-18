if ! which rails &> /dev/null; then
  return
fi

alias rdm='bundle exec rake db:migrate'
alias rdmt='rake db:migrate RAILS_ENV=test'
alias rdr='bundle exec rake db:rollback'
alias ram='bundle exec rake apartment:migrate'
alias rgm='bundle exec rails generate migration'
alias rc='rails console'
alias beg='bundle exec guard'
