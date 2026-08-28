# ORACLE & SQL CONFIG PATHS

# client / shell snippet configuration
export ORACLE_HOME="/Users/javiercoscolla/bin/instantclient_19_16"
export PATH="$ORACLE_HOME:$PATH"

# SQLPlus Library PATH
export DYLD_FALLBACK_LIBRARY_PATH="$ORACLE_HOME:$DYLD_FALLBACK_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$ORACLE_HOME:$DYLD_LIBRARY_PATH"

# ORACLE & SQLPATH
export SQLPATH="${HOME}/.oci:${HOME}/.sqlplus/client:${HOME}/.sqlplus/client/scripts"
export ORACLE_PATH="$SQLPATH"

# Language
export NLS_LANG="AMERICAN_AMERICA.UTF8"
