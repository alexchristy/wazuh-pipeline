#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"

# =====( MAIN )===== #

# Logging
setup_logging

# Ensure that we have root permissions
# so that we can modify the /var/ossec dir
if ! check_root; then
  exit "$EXIT_ERR"
fi

# Check all proper directories exist
if ! check_dir_exists "$WAZUH_HOME"; then
  exit "$EXIT_ERR"
fi

if ! check_dir_exists "$DEFAULT_RULES_HOME"; then
  exit "$EXIT_ERR"
fi

if ! check_dir_exists "$DEFAULT_DECODERS_HOME"; then
  exit "$EXIT_ERR"
fi

if ! check_dir_exists "$CUSTOM_RULES_HOME"; then
  exit "$EXIT_ERR"
fi

if ! check_dir_exists "$CUSTOM_DECODERS_HOME"; then
  exit "$EXIT_ERR"
fi

# Copy over the custom rules and decoders
if has_xml_files "$REPO_RULES"; then
  run_command "cp ""$REPO_RULES""/* $CUSTOM_RULES_HOME" "Failed to copy custom rule files from $REPO_RULES to $CUSTOM_RULES_HOME"
  run_command "chmod -R 660 $CUSTOM_RULES_HOME/*.xml" "Failed to set 660 permissions on rule files in $CUSTOM_RULES_HOME"
  run_command "chown $WAZUH_USER:$WAZUH_GROUP -R $CUSTOM_RULES_HOME/*.xml" "Failed to chown rule files in $CUSTOM_RULES_HOME"
  log_message "$INFO_LVL" "Successfully copied over custom rules."
  HAVE_CUSTOM_RULES=true
else
  log_message "$WARN_LVL" "No rule files found in $REPO_RULES. Are they missing?"
fi

if has_xml_files "$REPO_DECODERS"; then
  run_command "cp ""$REPO_DECODERS""/* $CUSTOM_DECODERS_HOME" "Failed to copy custom decoder files from $REPO_DECODERS to $CUSTOM_DECODERS_HOME"
  run_command "chmod -R 660 $CUSTOM_DECODERS_HOME/*.xml" "Failed to set 660 permissions on decoder files in $CUSTOM_DECODERS_HOME"
  run_command "chown $WAZUH_USER:$WAZUH_GROUP -R $CUSTOM_DECODERS_HOME/*.xml" "Failed to chown rule files in $CUSTOM_DECODERS_HOME"
  log_message "$INFO_LVL" "Successfully copied over custom decoders."
  HAVE_CUSTOM_DECODERS=true
else
  log_message "$WARN_LVL" "No decoder files found in $REPO_DECODERS. Are they missing?"
fi

# The rest of the script logic is only for installing decoders
# so if there are no custom decoders we should just restart the
# wazuh manager for the rules to become active
if [ "$HAVE_CUSTOM_DECODERS" = false ]; then

  # NO DECODERS; YES RULES
  if [ "$HAVE_CUSTOM_RULES" = true ]; then
    if restart_wazuh; then
      exit "$EXIT_SUCCESS"
    else
      exit "$EXIT_ERR"
    fi

  # NO DECODERS; NO RULES
  else
    exit "$EXIT_SUCCESS"
  fi

fi

# Temporary file to store the results
tmpfile=$(mktemp) || exit 1
dedup_tmpfile=$(mktemp) || exit 1
disable_tmpfile=$(mktemp) || exit 1

# Ensure the temporary files are removed on script exit
trap 'rm -f "$tmpfile" "$dedup_tmpfile" "$disable_tmpfile"' EXIT

# Collect decoders from the repository files
for file in "$REPO_DECODERS"/*; do
  grep -oP '<decoder.*?>' "$file" >> "$tmpfile"
done

# Deduplicate the decoders and store them in a second temporary file
sort -u "$tmpfile" > "$dedup_tmpfile"

# Create a file descriptor for reading the deduplicated decoders
exec 3< "$dedup_tmpfile"

# Flag to track if any decoder is disabled
DISABLED_DECODERS=false

# Collect the default decoders that need to be disabled
while IFS= read -r decoder <&3; do
  echo "Processing decoder: $decoder" # Debug statement
  # Capture the list of default decoders that collide with our custom decoders
  tmpfile2=$(mktemp) || exit 1
  trap 'rm -f "$tmpfile2"' EXIT

  grep -R "$decoder" "$DEFAULT_DECODERS_HOME" | awk -F: '{print $1}' | sort -u >> "$disable_tmpfile"

  rm -f "$tmpfile2"
done

# Close the file descriptor
exec 3<&-

# Deduplicate the list of default decoders to disable
sort -u "$disable_tmpfile" > "$dedup_tmpfile"

# Create a file descriptor for reading the finalized list of default decoders to disable
exec 4< "$dedup_tmpfile"

# Process the deduplicated list of default decoders
while IFS= read -r def_decoder <&4; do
  echo "Disabling default decoder: $def_decoder" # Debug statement
  if [ "$DISABLED_DECODERS" = false ]; then
    DISABLED_DECODERS=true
  fi

  partial_decoder_path=${def_decoder#"$WAZUH_HOME/"}
  exclusion_line="<decoder_exclude>$partial_decoder_path</decoder_exclude>"

  # Check to see if line already exists and skip it if it does
  if grep -q "$exclusion_line" "$WAZUH_SETTINGS"; then
    log_message "$INFO_LVL" "Skipping entry $exclusion_line. Already exists in $WAZUH_SETTINGS!"
    continue
  fi

  # Add proper spacing
  exclusion_line="    $exclusion_line"

  if add_ruleset_config "$exclusion_line"; then
    log_message "$INFO_LVL" "Successfully added decoder exclusion: $exclusion_line"
  else
    log_message "$ERR_LVL" "Failed to add decoder exclusion: $exclusion_line"
    exit "$EXIT_ERR"
  fi
done

# Close the file descriptor
exec 4<&-

# Set the correct permissions on the new config file
run_command "chgrp $WAZUH_GROUP $WAZUH_SETTINGS" "Failed to change $WAZUH_SETTINGS file to the $WAZUH_GROUP."
run_command "chmod 660 $WAZUH_SETTINGS" "Failed to add RW permissions to $WAZUH_SETTINGS for the $WAZUH_GROUP group."

# Clean up the temporary files
rm -f "$tmpfile" "$dedup_tmpfile" "$disable_tmpfile"

# Restart Wazuh
if restart_wazuh; then
  exit "$EXIT_SUCCESS"
else
  exit "$EXIT_ERR"
fi