#!/usr/bin/env bash
#
# This script bootstraps an OpenLDAP environment with example users, using either
# a supplied or randomly generated password.

set -e

# Set static variable and create readonly user by default
LDIF_FILE=/container/service/slapd/assets/config/bootstrap/ldif/example.ldif
export LDAP_READONLY_USER=true
export LDAP_READONLY_USER_USERNAME=readonly


# Check to make sure it's already bootstrapped, otherwise it will replace the
# previous password if stopped and started back up again.
if [ ! -f /var/run/openldap.bootstrapped ]; then
    if [ ! ${LDAP_ADMIN_PASSWORD} ] || [ ${LDAP_ADMIN_PASSWORD} = "" ]; then
        # If no password supplied then generate a random one of 14 characters and apply to all users.
        RANDOM_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c14)
        # Set all users to the same password
        export LDAP_ADMIN_PASSWORD=${RANDOM_PASSWORD}
        export LDAP_CONFIG_PASSWORD=${RANDOM_PASSWORD}
        export LDAP_READONLY_USER_PASSWORD=${RANDOM_PASSWORD}
        # Encrypt random password as md5crpyt and escape special characters for sed
        MD5CRYPT_RANDOM_PASSWORD=$(openssl passwd -1 ${RANDOM_PASSWORD} | sed -e 's/[()&\/!%$*#@^+.]/\\&/g')
        sed -i "s|REPLACE_PASSWORD|\{CRYPT\}${MD5CRYPT_RANDOM_PASSWORD}|" ${LDIF_FILE}
        echo "#################################################"
        echo "The password for all users is: ${RANDOM_PASSWORD}"
        echo "#################################################"
    else
        if [ ${#LDAP_ADMIN_PASSWORD} -lt 8 ]; then
            echo "ERROR: Password length is too short. Please enter a longer password with a minimum of 8 characters."
            exit 1
        fi
        # Set all users to the same supplied password
        export LDAP_READONLY_USER_PASSWORD=${LDAP_ADMIN_PASSWORD}
        export LDAP_CONFIG_PASSWORD=${LDAP_ADMIN_PASSWORD}
        # Encrypt supplied password as md5crpyt and escape special characters for sed
        MD5CRYPT_PASSWORD=$(openssl passwd -1 ${LDAP_ADMIN_PASSWORD} | sed -e 's/[()&\/!%$*#@^+.]/\\&/g')
        sed -i "s|REPLACE_PASSWORD|\{CRYPT\}${MD5CRYPT_PASSWORD}|" ${LDIF_FILE}
        echo "#################################################"
        echo "The password for all users is: ${LDAP_ADMIN_PASSWORD}"
        echo "#################################################"
    fi
    # Set to bootstrapped, preventing overwriting the password with each start-up
    touch /var/run/openldap.bootstrapped
else
    echo "OpenLDAP already bootstrapped, proceeding..."
fi

# Still enable debug mode through an environment variable
if [[ ${DEBUG} = "true" ]]; then
    /container/tool/run --loglevel debug
else
    /container/tool/run
fi

exec "$@"
