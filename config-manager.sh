#!/bin/bash

# Generic shell script for managing snippet installation in ~/.bashrc
# This script can install/remove any snippet by name

# Helper function to generate markers for a snippet
generate_markers() {
    local snippet_name="$1"
    begin_marker="# BEGIN $snippet_name snippet"
    end_marker="# END $snippet_name snippet"
}

# Helper function to extract snippet name from file path
extract_snippet_name() {
    local snippet_file="$1"
    local snippet_name="${snippet_file##*/}"
    echo "${snippet_name%.snippet.sh}"
}

# Helper function to check if a snippet is installed
is_snippet_installed() {
    local snippet_name="$1"
    generate_markers "$snippet_name"
    grep -q "$begin_marker" ~/.bashrc
}

# Helper function to iterate through all snippet files
iterate_snippets() {
    local callback_function="$1"
    
    # Find all .snippet.sh files in bash-snippets folder
    for snippet_file in bash-snippets/*.snippet.sh; do
        # Check if glob didn't match any files
        if [[ ! -f "$snippet_file" ]]; then
            echo "No .snippet.sh files found in bash-snippets directory"
            return 1
        fi
        
        local snippet_name
        snippet_name=$(extract_snippet_name "$snippet_file")
        
        # Call the callback function with the snippet name
        $callback_function "$snippet_name"
    done
}

# Batch functions for all snippets
install_all() {
    local installed_count=0
    local already_installed_count=0
    
    # Callback function for each snippet
    process_install() {
        local snippet_name="$1"
        
        if ! is_snippet_installed "$snippet_name"; then
            install_snippet "$snippet_name"
            ((installed_count++))
        else
            echo "$snippet_name snippet already installed"
            ((already_installed_count++))
        fi
    }
    
    iterate_snippets process_install
    echo "Summary: $installed_count installed, $already_installed_count already installed"
}

remove_all() {
    local removed_count=0
    local not_found_count=0
    
    # Callback function for each snippet
    process_remove() {
        local snippet_name="$1"
        
        if is_snippet_installed "$snippet_name"; then
            remove_snippet "$snippet_name"
            ((removed_count++))
        else
            echo "$snippet_name snippet not found in ~/.bashrc"
            ((not_found_count++))
        fi
    }
    
    iterate_snippets process_remove
    echo "Summary: $removed_count removed, $not_found_count not found"
}

# List all available snippets and their installation status
list() {
    echo "Available snippets in bash-snippets/:"
    echo "======================================"
    
    # Callback function for each snippet
    process_list() {
        local snippet_name="$1"
        
        if is_snippet_installed "$snippet_name"; then
            echo "  ✔ $snippet_name"
        else
            echo "  ✘ $snippet_name"
        fi
    }
    
    iterate_snippets process_list
    
    echo ""
    echo "Use 'install-snippet <name>' to install a specific snippet"
    echo "Use 'install-all' to install all snippets"
}

# Generic functions (for comparison with original functions above)
install_snippet() {
    local snippet_name="$1"
    
    if [[ -z "$snippet_name" ]]; then
        echo "Error: snippet name is required"
        return 1
    fi
    
    # Construct filename from snippet name (look in bash-snippets folder)
    local snippet_file="bash-snippets/${snippet_name}.snippet.sh"
    
    if [[ ! -f "$snippet_file" ]]; then
        echo "Error: snippet file '$snippet_file' not found"
        return 1
    fi
    
    # Generate markers based on snippet name
    generate_markers "$snippet_name"
    
    if ! grep -q "$begin_marker" ~/.bashrc; then
        # Add the snippet with markers
        echo ""                >> ~/.bashrc
        echo "$begin_marker"   >> ~/.bashrc
        cat "$snippet_file"    >> ~/.bashrc
        echo "$end_marker"     >> ~/.bashrc

        echo "$snippet_name snippet installed to ~/.bashrc"
    else
        echo "$snippet_name snippet already installed"
    fi
}

remove_snippet() {
    local snippet_name="$1"
    
    if [[ -z "$snippet_name" ]]; then
        echo "Error: snippet name is required"
        return 1
    fi
    
    # Generate markers based on snippet name
    generate_markers "$snippet_name"
    
    if grep -q "$begin_marker" ~/.bashrc; then
        # Use sed to delete all lines between (and including) the markers
        # -i flag: edit file in-place
        # '/pattern1/,/pattern2/d': delete lines from pattern1 to pattern2 (inclusive)
        sed -i "/$begin_marker/,/$end_marker/d" ~/.bashrc
        echo "$snippet_name snippet removed from ~/.bashrc"
    else
        echo "$snippet_name snippet not found in ~/.bashrc"
    fi
}

# Function to show usage information
usage() {
    echo "Usage: $0 {install-all|remove-all|install-snippet|remove-snippet|list}"
    echo "  install-all                      - Install ALL .snippet.sh files from bash-snippets/ (batch operation)"
    echo "  remove-all                       - Remove ALL .snippet.sh files from bash-snippets/ (batch operation)"
    echo "  install-snippet <name>           - Install specific snippet by name (generic function)"
    echo "  remove-snippet <name>            - Remove specific snippet by name (generic function)"
    echo "  list                             - List all available snippets and their installation status"
    echo ""
    echo "Generic functions expect files named: bash-snippets/<name>.snippet.sh"
    echo ""
    echo "Examples:"
    echo "  $0 list                          # Shows all snippets with ✔/✘ status"
    echo "  $0 install-all                   # Installs all bash-snippets/*.snippet.sh files"
    echo "  $0 remove-all                    # Removes all bash-snippets/*.snippet.sh files"
    echo "  $0 install-snippet \"git-prompt\"  # Installs bash-snippets/git-prompt.snippet.sh"
    echo "  $0 remove-snippet \"my-aliases\"   # Removes my-aliases snippet from ~/.bashrc"
    exit 1
}

# Main script logic
get_current_shell
case "$1" in
    install-all)
        install_all
        ;;
    remove-all)
        remove_all
        ;;
    install-snippet)
        install_snippet "$2"
        ;;
    remove-snippet)
        remove_snippet "$2"
        ;;
    list)
        list
        ;;
    *)
        usage
        ;;
esac
