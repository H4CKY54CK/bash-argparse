#!/usr/bin/env bash

## Debugging stuff.
colorize ()
{
  case ${use_color:-"auto"} in
    always )
      printf "${1}"
      ;;
    auto )
      if [ -t 1 ]; then
        printf "${1}"
      else
        printf "${1}" | perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip($_)'
      fi
      ;;
    * )
      printf "${1}" | perl -MTerm::ANSIColor=colorstrip -ne 'print colorstrip($_)'
      ;;
  esac
}

info_msg () { colorize "\x1b[34m[$(basename "${0}") info]\x1b[m: ${1}\n"; }
warn_msg () { colorize "\x1b[33m[$(basename "${0}") warn]\x1b[m: ${1}\n"; }
error_msg () { >&2 colorize "\x1b[31m[$(basename "${0}") error]\x1b[m: ${1}\n"; exit 1; }



ArgumentParser ()
{
  # The plan is to add some default stuff here, like argparse.ArgumentParser() does
  declare -Ag "${1}"
  local -n ref="${1}"
  ref[test]="hello"
}


add_argument ()
{
  # This function takes these positional parameters in this order:
  #   1  - The namespace of the parser, as a string. This could provide a simple way to use subparsers.
  #   2  - The desired key name by which to store the argument. AKA 'dest'
  # And the following keyword arguments to populate the attributes of the argument
  #   long   - The long name for this argument.
  #   short  - The short name for this argument.
  #   action - The action to take when this argument is provided. The following actions are supported:
  #       store       - Store the value that follows the argument. 'nargs' is currently not supported, but soon.
  #       store_true  - Store the boolean 'true', if this argument is provided.
  #       store_false - Store the boolean 'false', if this argument is provided.

  local -n ref="${1}"
  shift

  local dest="${1}"
  shift

  while [ $# -gt 0 ]; do
    case $1 in
      long=* )
        ref[${dest}.long]="${1#long=}"
        shift
        ;;
      short=* )
        ref[${dest}.short]="${1#short=}"
        shift
        ;;
      action=* )
        ref[${dest}.action]="${1#action=}"
        shift
        ;;
      * )
        error_msg "Unrecognized options to ${FUNCNAME[0]}"
        ;;
    esac
  done
}


parse_args ()
{
  # This function takes these positional parameters in this order:
  #   1  - The namespace of the parser, as a string.
  #   2  - The desired namespace of the resulting values, as a string.
  #   3+ - The arguments to parse. Typically, you would just pass "$@" here.

  declare -n ref="${1}"
  declare -Ag "${2}"
  declare -n target="${2}"

  # Shift the namespace out of the args. Easy to forget about.
  shift 2

  local key

  # Iterate over the numbered args
  while [ $# -gt 0 ]; do
    # Iterate over the namespace args as one giant list (unfortunate) (maybe store the dests and this could provide a 
    # way to skip most of them)
    for key in "${!ref[@]}"; do
      # Get short/long name
      case $key in
        *.short | *.long )
          # PARSE! THAT! ARG!
          case $1 in
            "${ref["${key}"]}" )
              # Determine action
              local dest="${key%.*}"
              local action="${ref["${dest}.action"]}"
              case "${action}" in
                store )
                  shift
                  target["${dest}"]="${1}"
                  shift
                  # This break COULD be useful, if we didn't need to iterate over every key in the namespace.
                  # break
                  ;;
                store_false | store_true )
                  shift
                  target["${dest}"]="${action#store_}"
                  # This break COULD be useful, if we didn't need to iterate over every key in the namespace.
                  # break
                  ;;
              esac
              ;;
          esac
          ;;
      esac
    done
    shift
  done
}



ArgumentParser parser

add_argument parser output short="-o" long="--output" action="store"
add_argument parser quiet short="-q" long="--quiet" action="store_true"

parse_args parser args "$@"

echo "output: ${args[output]}"
echo "quiet: ${args[quiet]}"
