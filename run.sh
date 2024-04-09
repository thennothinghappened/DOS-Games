#! /bin/bash
#
# Note: this script is expected to run under my own system using WSL2, DOSBox and nasm
# It probably won't be of much help if you intend to run this yourself!
# 
# The script is also - as should be pretty obvious - needlessly overcomplicated, since this
# is also an opportunity to learn some bash :P

shopt -s nullglob

readonly DOSBOX_PATH='/mnt/c/Program Files (x86)/DOSBox-0.74-3/DOSBox.exe'
readonly DOSBOX_ARGS=('-noconsole')

readonly PROGRAMS=('dos_test')

#####################################
# List the programs to choose from
# 
# Outputs:
#     Newline-separated program list
#####################################
program_list() {

    local program

    for program in ${PROGRAMS[@]}; do
        printf '\t- %s\n' $program
    done

}

#####################################
# Check if the program supplied is
# valid in our list of programs
# 
# Arguments:
#     program_to_check: string
#
# Returns:
#    Result: 0 = success
#####################################
program_exists() {

    local program_to_check="$1"
    local program

    for program in ${PROGRAMS[@]}; do

        if [ "$program" = "$program_to_check" ]; then
            return 0
        fi

    done

    return 1

}

#####################################
# Assemble the program with nasm
#
# Arguments:
#     program: string
#     output_filename: string
# 
# Returns:
#    Status: 0 = success
#####################################
program_assemble() {
    
    local program="$1"
    local output_filename="$2"
    local nasm_output

    nasm_output=$(nasm -f bin -o "$output_filename" "$program.asm" 2>&1)

    if [ $? -ne 0 ]; then

        echo '-- Failed to assemble with NASM --'
        echo "$nasm_output"

        return 1
    fi

    return 0

}

#####################################
# Show the usage text.
#
# Outputs:
#     Program usage information.
#####################################
usage() {

    echo 'Usage: [<dos/boot> <program>] or [clean]'
    echo 'Programs:'

    program_list
}

#####################################
# Clean up created program binaries.
#####################################
clean_output_files() {

    local com_files=(./*.COM)
    local bin_files=(./*.bin)

    if [ ${#com_files} -ne 0 ]; then
        rm "${com_files[@]}"
    fi

    if [ ${#bin_files} -ne 0 ]; then
        rm "${bin_files[@]}"
    fi

}

#####################################
# Handler for on Ctrl+C.
# Closes DOSBox or QEmu.
#####################################
stop_handler() {

    # TODO: haven't found a way to `kill` a Windows process by the provided PID in WSL...
    # Using powershell to dirty-ly get around it.

    if [ "$platform" = 'boot' ]; then
        # QEmu
        echo 'Not yet implemented!'
        exit 1
    fi

    # DOSBox
    printf '\nEnding DOSBox session.\n'
    powershell.exe "Stop-Process -Name DOSBox"

    exit 0

}

####################################################################################################
# Start of execution
####################################################################################################

# Clean up output files
if [ $# -eq 1 ]; then

    if [ "$1" != 'clean' ]; then
        usage
        exit 1
    fi

    clean_output_files
    exit 0

fi

if [ $# -ne 2 ]; then
    usage
    exit 1
fi

# Whether to run on DOS or as an MBR boot sector application
readonly platform="$1"

# The program chosen by the user to load
readonly program_chosen="$2"

$(program_exists "$program_chosen"); if [ $? -ne 0 ]; then

    printf 'The program "%s" is not valid, choose from:\n' "$program_chosen"
    program_list

    exit 1

fi

case "$platform" in

    'dos')

        output_filename="$program_chosen.COM"
        assemble_output=$(program_assemble "$program_chosen" "$output_filename")

        if [ $? -ne 0 ]; then
            echo "$assemble_output"
            exit 1
        fi

        printf 'Running "%s" in DOSBox...\n' "$output_filename"

        trap stop_handler SIGINT SIGTERM
        "$DOSBOX_PATH" "$output_filename" "${DOSBOX_ARGS[@]}"

        exit 0
    ;;

    'boot')
        echo 'Not yet implemented!'
        exit 1
    ;;

    *)
        printf 'Choose an execution type: (dos, boot)\n\n'

        usage
        exit 1
    ;;

esac
