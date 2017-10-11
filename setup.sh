#!/bin/bash

UCP=35.161.219.20
USER=admin
PASS=docker123

# Run this on your UCP controller to set up LDAP backend
docker run --name orcabank-ldap --constraint "node.role=manager" -p 389:389 -p 636:636 --detach -v /docker-access-control:/ldap osixia/openldap:1.1.9


docker service create --name orcabank-ldap --constraint "node.role==manager" -p 389:389 -p 636:636 --detach --mount "type=bind,source=/docker-access-control,target=/ldap" osixia/openldap:1.1.9
# Check users in LDAP
docker exec openldap ldapsearch -x -h localhost -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w fwZk1lsN5C7GU8

docker exec orcabank-ldap ldapsearch -x -h localhost -b dc=orcabank,dc=com -D "cn=admin,dc=example,dc=org" -w admin



# LDAP Admin Console
docker run -p 6443:443 \
       --env PHPLDAPADMIN_LDAP_HOSTS=ldap://localhost \
       --detach osixia/phpldapadmin:0.7.0

# Add users to LDAP
docker exec orcabank-ldap ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /ldap/orcabank.ldif -h localhost -ZZc


# Create /Shared/mobile and /Shared/payments collections
token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

shared_mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)

shared_payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)

#write id to a tmp file
echo $shared_payments_id > col_tmp.txt
echo $shared_mobile_id >> col_tmp.txt


function basic-demo-setup() {

  echo -n "Creating Orgs and Teams"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

  curl -sk -X POST https://${UCP}/accounts/ -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"orcabank\",\"isOrg\":true}" > /dev/null 2>&1

  ops_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"ops\",\"description\":\"ops team of awesomeness\"}" | jq -r .id)

  mobile_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"mobile\",\"description\":\"dev team of awesomeness\"}" | jq -r .id)

  payments_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"payments\",\"description\":\"dev team of awesomeness\"}" | jq -r .id)

  security_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"security\",\"description\":\"security team of awesomeness\"}" | jq -r .id)
  echo "$GREEN" "[ok]" "$NORMAL"

  echo -n "Inputing Users"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"sri-mobile\",\"password\":\"docker123\",\"first_name\":\"sri mobile backend developer\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"ashley-payments\",\"password\":\"docker123\",\"first_name\":\"ashley payments developer\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"tim-ops\",\"password\":\"docker123\",\"first_name\":\"tim ops\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"angela-security\",\"password\":\"docker123\",\"first_name\":\"angela SecOps\"}"

  curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"andy\",\"password\":\"docker123\",\"first_name\":\"andy $USER\"}"
  echo "$GREEN" "[ok]" "$NORMAL"

  echo -n "Adding Users to Teams"
  token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/ops/members/tim-ops" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1

  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/security/members/angela-security" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1

  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/mobile/members/sri-mobile" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1

  curl -skX PUT "https://${UCP}/accounts/orcabank/teams/payments/members/ashley-payments" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1
  echo "$GREEN" "[ok]" "$NORMAL"


	#Create /Shared/mobile and /Shared/payments collections
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1

	shared_mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)

	shared_payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)

}











prod_col_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"prod\",\"path\":\"/\",\"parent_id\": \"swarm\"}" | jq -r .id)

mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"path\":\"/prod\",\"parent_id\": \"$prod_col_id\"}" | jq -r .id)

payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"path\":\"/prod\",\"parent_id\": \"$prod_col_id\"}" | jq -r .id)


echo $payments_id >> col_tmp.txt
echo $mobile_id >> col_tmp.txt
echo $prod_col_id >> col_tmp.txt
