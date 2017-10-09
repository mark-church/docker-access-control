#!/bin/bash

# Run this on your UCP controller to set up LDAP backend
docker run --name orcabank-ldap -p 389:389 -p 636:636 --detach -v /docker-access-control:/ldap osixia/openldap:1.1.9

# Check users in LDAP
docker exec orcabank-ldap ldapsearch -x -h localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin

docker exec orcabank-ldap ldapsearch -x -h localhost -b dc=orcabank,dc=com -D "cn=admin,dc=example,dc=org" -w admin



# LDAP Admin Console
docker run -p 6443:443 \
       --env PHPLDAPADMIN_LDAP_HOSTS=ldap://localhost \
       --detach osixia/phpldapadmin:0.7.0

# Add users to LDAP
docker exec orcabank-ldap ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /ldap/orcabank.ldif -h localhost -ZZc
