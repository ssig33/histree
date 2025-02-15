#!/usr/bin/env fish

# Set default configuration paths and values
set -g HISTREE_HOME (dirname (status -f))
set -g HISTREE_BIN "$HISTREE_HOME/bin/histree"
set -g HISTREE_DB (set -q HISTREE_DB; and echo $HISTREE_DB; or echo "$HOME/.histree.db")
set -g HISTREE_LIMIT (set -q HISTREE_LIMIT; and echo $HISTREE_LIMIT; or echo 100)

# Build the binary if it doesn't exist
if not test -x $HISTREE_BIN
    echo "Building histree..."
    pushd $HISTREE_HOME
    go build -o bin/histree ./cmd/histree
    popd
end

# Generate unique session label when the plugin is loaded
set -g _HISTREE_START_TIME (date +"%Y%m%d-%H%M%S")
set -g _HISTREE_SESSION_LABEL (hostname):$_HISTREE_START_TIME:$$

# Function to add a command to history
function _histree_add_command
    set -l cmd $_HISTREE_LAST_CMD
    set -l exit_code $_HISTREE_LAST_EXIT_CODE

    # If the command is empty, do not record it
    if test -z "$cmd"
        return
    end

    echo "$cmd" | $HISTREE_BIN -db "$HISTREE_DB" -action add -dir "$PWD" \
        -session "$_HISTREE_SESSION_LABEL" \
        -exit "$exit_code"
end

# Function to capture the last command
function _histree_preexec --on-event fish_preexec
    set -g _HISTREE_LAST_CMD $argv
end

# Function to capture the last exit code
function _histree_precmd --on-event fish_prompt
    set -g _HISTREE_LAST_EXIT_CODE $status
    _histree_add_command
end

# Function to display history
function histree
    set -l format "simple"
    set -l verbose false
    set -l json false

    for arg in $argv
        switch $arg
            case -v --verbose
                set format "verbose"
                set verbose true
            case -json --json
                set format "json"
                set json true
        end
    end

    $HISTREE_BIN -db "$HISTREE_DB" -action get -limit "$HISTREE_LIMIT" -dir "$PWD" -format "$format"
end

# Add aliases for showing history
alias histree='histree'
