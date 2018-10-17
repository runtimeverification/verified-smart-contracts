# Usage in evm-semantics/tests/proofs:
# E.g. ./run-proofs gnosis-erc20 gnosis-erc20-1
# $1: folder in ./specs
# $2: output folder
# $3...: files to be verified
# OR
# $3: all/empty = all 
# transferFrom-success-2-spec.k

options=( \
'--log-basic' \
'--log-cells "(k),(gas),(statusCode)"' \
# '--log-cells "(k),(output),(localMem),(pc),(gas),(wordStack),(accounts)' \
)

output_top_dir="output"
output_dir="$2"

mkdir -p "$output_top_dir/$output_dir"
touch "$output_top_dir/$output_dir/log"

run_proof() {
    touch "$output_top_dir/$output_dir/$file_name"

    cmd_part1="kprove "$file_path" -d "../../.build/java" -m VERIFICATION"
    cmd_part2="&> "$output_top_dir/$output_dir/$file_name""
    cmd="$cmd_part1 ${options[@]} $cmd_part2"

    log="$(date): Verifying $file_name with ${options[@]}"
    echo "$log" >> "$output_top_dir/$output_dir/log"
    echo "$log"

    eval "$cmd"
}

if [ "$3" == "all" ] || [ -z "$3" ]
then
    for file in ./specs/"$1"/*
    do
        file_name="${file##*/}"
        file_end="${file:(-6)}"
        if [ "$file_end" == "spec.k" ]
        then
            file_path="${file:2}"
            run_proof "$@"
        else
            echo "skipping $file_name because it is not a spec file"
        fi
    done
else
    i=3
    if [ "$3" == "-d" ]
    then
        echo "deleting $output_top_dir/$output_dir"
        rm -rf "$output_top_dir/$output_dir/*"
        i=4
    fi
    for ((j=i; j <= $#; j++ )); do
        file_name="${!j}"
        file_path="specs/$1/$file_name"
        if [ -e "$file_path" ]
        then
            run_proof "$@"
        else
            echo "skipping $file_name because it does not exist - maybe a typo?"
        fi
    done
fi