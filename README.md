# Please don't actually use this lol

## Demo

Try it out:  
`bash_argparse.sh --output somestring --quiet`  
`bash_argparse.sh -o somestring -q`  

## A little explanation

It works almost the same way as `argparse` from Python. You do a little  
`ArgumentParser parser`  
to create the namespace, and a sprinkle of  
`add_argument parser output short="-o" long="--output" action="store"`  
`add_argument parser quiet short="-q" long="--quiet" action="store_true"`  
and finally a  
`parse_args parser args "$@"`  
and you have a CLI. :P
