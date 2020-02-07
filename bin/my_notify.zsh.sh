# Example usage:
#   echo ""; my_notify
# https://stackoverflow.com/a/9502698/792789

# set -o history -o histexpand
my_notify() {
#  declare last_exit_code="${?}" last_command="${_}" ;

  last_exit_code=$?
  last_command=$history[$HISTCMD]

  # Bash Ternary: https://stackoverflow.com/a/3953666/792789
  [[ $last_exit_code == 0 ]] && m="succeed" ||  m="failed"
#   terminal-notifier -message "$last_command $m" # old way
  osascript -e "display notification \"$last_command completed $m\" with title \"$m\""
}

