#!/bin/sh
set -eu

qesc() {
  RET="$1"
  set -- ""
  while : ; do
    case "$RET" in
      ( *"'"* )
        set -- "$1${RET%%"'"*}'\\''"
        RET="${RET#*"'"}"
        ;;
      ( * )
        RET="'$1$RET'"
        break
        ;;
    esac
  done
}

opt_parser_get_arg_count() {
  RET="$1"
  eval "set -- $2"
  while [ $# -gt 0 ]; do
    case "$1" in ( "$RET:"?* )
      RET="${1#"$RET:"}"
      return 0
    esac
    shift
  done
  RET=0
  return 0
}

opt_parser() {
  _opt_parser_options=""
  _opt_parser_normal_args=""
  _opt_parser_option_args=""

  while [ $# -gt 0 ]; do

    case "$1" in
      ( '--' )
        shift
        break
        ;;
      ( ?':'?* ) qesc "-$1" ;;
      ( ?*':'?* ) qesc "--$1" ;;
      ( ? ) qesc "-$1:1" ;;
      ( ?* ) qesc "--$1:1" ;;
      ( * )
        shift
        continue
        ;;
    esac

    _opt_parser_options="$_opt_parser_options $RET"
    shift
  done

  while [ $# -gt 0 ]; do
    case "$1" in
      ( '--' )
        shift
        break
        ;;
      ( '--'* | '-'? )
        case "$1" in ( "--"?*"="* )
          RET="$1"
          shift
          set -- "${RET%%"="*}" "${RET#*"="}" "$@"
          continue
        esac

        opt_parser_get_arg_count "$1" "$_opt_parser_options"
        _opt_parser_arg_count="$RET"

        if [ $# -gt "$_opt_parser_arg_count" ]; then
          while [ "$_opt_parser_arg_count" -ge 0 ]; do
            qesc "$1"
            _opt_parser_option_args="$_opt_parser_option_args $RET"
            shift
            _opt_parser_arg_count=$((_opt_parser_arg_count - 1))
          done
        else
          shift
        fi
        ;;
      ( '-'?* )
        opt_parser_get_arg_count "${1%"${1#??}"}" "$_opt_parser_options"
        if [ "$RET" -eq 1 ]; then
          RET="$1"
          shift
          set -- "${RET%"${RET#??}"}" "${RET#??}" "$@"
          continue
        fi

        _opt_parser_short_opts="${1#'-'}"
        while [ "$_opt_parser_short_opts" != "" ]; do
          _opt_parser_short_opt="-${_opt_parser_short_opts%"${_opt_parser_short_opts#?}"}"
          opt_parser_get_arg_count "$_opt_parser_short_opt" "$_opt_parser_options"
          if [ "$RET" -eq 0 ] && [ "$_opt_parser_short_opt" != '--' ]; then
            qesc "$_opt_parser_short_opt"
            _opt_parser_option_args="$_opt_parser_option_args $RET"
          fi
          _opt_parser_short_opts="${_opt_parser_short_opts#?}"
        done
        shift
        ;;
      ( * )
        qesc "$1"
        _opt_parser_normal_args="$_opt_parser_normal_args $RET"
        shift
        ;;
    esac
  done

  while [ $# -gt 0 ]; do
    qesc "$1"
    _opt_parser_normal_args="$_opt_parser_normal_args $RET"
    shift
  done

  RET="${_opt_parser_option_args#' '} -- ${_opt_parser_normal_args#' '}"
}

opt_parser "$@"

echo "$RET"
