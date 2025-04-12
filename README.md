# opt_parser

e.g.

script.sh
~~~bash
opt_parser p:1 params:3 -- "$@"
eval "set -- $RET"
while [ $# -gt 0 ]; do
    case "$1" in
        ( -- )
            shift
            break
            ;;
        ( -a )
            echo "option a"
            shift
            ;;
        ( -b )
            echo "option b"
            shift
            ;;
        ( -p )
            echo "option p"
            shift
            echo "    $1"
            shift
            ;;
        ( --abc )
            echo "option abc"
            shift
            ;;
        ( --params )
            echo "option params"
            shift
            echo "    $1"
            echo "    $2"
            echo "    $3"
            shift 3
            ;;
    esac
done
~~~

command
`./script.sh -ab -p 123 --abc --params A B C`

output
~~~
option a
option b
option p
    123
option abc
option params
    A
    B
    C
~~~
