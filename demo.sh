function login() {
	UCP=ucp.orcabank.dckr.org
	USER=admin
	PASS=docker123
	GREEN=$(tput setaf 2)
	NORMAL=$(tput sgr0)
	echo "$GREEN" "Login information set for $UCP" "$NORMAL"
}

function create_users_teams(){
	echo "$GREEN" "Creating teams and orgs" "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	curl -sk -X POST https://${UCP}/accounts/ -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"orcabank\",\"isOrg\":true}" > /dev/null 2>&1
	ops_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"ops\",\"description\":\"ops team of awesomeness\"}" | jq -r .id)
	mobile_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"mobile\",\"description\":\"dev team of awesomeness\"}" | jq -r .id)
	payments_team_id=$(curl -sk -X POST https://${UCP}/accounts/orcabank/teams -H "Authorization: Bearer $token" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -d "{\"name\":\"payments\",\"description\":\"dev team of awesomeness\"}" | jq -r .id)

	echo "$GREEN" "Inputting users" "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"ashley\",\"password\":\"docker123\",\"first_name\":\"ashley admin\"}"
	curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"mindi\",\"password\":\"docker123\",\"first_name\":\"mindi mobile developer\"}"
	curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"peter\",\"password\":\"docker123\",\"first_name\":\"peter payments developer\"}"
	curl -skX POST "https://${UCP}/api/accounts" -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $token" -d  "{\"role\":1,\"username\":\"omar\",\"password\":\"docker123\",\"first_name\":\"omar ops engineer\"}"

	echo "$GREEN" "Setting up team membership" "$NORMAL"
	sleep 1
	echo "$GREEN" " ... promising not to leave anybody out." "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	curl -skX PUT "https://${UCP}/accounts/orcabank/teams/ops/members/omar" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1
	curl -skX PUT "https://${UCP}/accounts/orcabank/teams/mobile/members/mindi" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1
	curl -skX PUT "https://${UCP}/accounts/orcabank/teams/payments/members/peter" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{}" > /dev/null 2>&1
}

function create_roles() {

	echo "$GREEN" "Creating 'developer' and 'use_networks_secrets' role" "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
    dev_role_id=$(curl -skX POST "https://${UCP}/roles" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"developer\",\"system_role\": false,\"operations\": {\"Container\":{\"Container Logs\": [],\"Container View\": []},\"Service\": {\"Service Logs\": [],\"Service View\": [],\"Service View Tasks\":[]}}}" | jq -r .id)
	use_networks_secrets_role_id=$(curl -skX POST "https://${UCP}/roles" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"View & Use Networks + Secrets\",\"system_role\": false,\"operations\": {\"Network\":{\"Network Connect\": [],\"Network Disconnect\": [],\"Network View\": []},\"Secret\": {\"Secret Use\": [],\"Secret View\": []}}}" | jq -r .id)
}


function create_collections_1() {
	
	echo "$GREEN" "Creating /Shared/mobile and /Shared/payments collections ..." "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	shared_mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)
	echo "$GREEN" "  - Created /Shared/mobile collection" "$NORMAL"
	shared_payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"path\":\"/\",\"parent_id\": \"shared\"}" | jq -r .id)
	echo "$GREEN" "  - Created /Shared/payments collection" "$NORMAL"
}

function remove_collections_1() {

	echo "$GREEN" "Removing /Shared/mobile and /Shared/payments collections" "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	curl -skX DELETE "https://${UCP}/collections/$shared_mobile_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
	curl -skX DELETE "https://${UCP}/collections/$shared_payments_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
}

function create_collections_2() {

	echo "$GREEN" "Creating /mobile, /payments, /db, /db/payments, and /db/mobile collections" "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"mobile\",\"parent_id\": \"swarm\"}" | jq -r .id)
	payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"parent_id\": \"swarm\"}" | jq -r .id)
	db_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"db\",\"parent_id\": \"swarm\"}" | jq -r .id)
	db_mobile_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"payments\",\"parent_id\": \"$db_id\"}" | jq -r .id)
	db_payments_id=$(curl -skX POST "https://${UCP}/collections" -H  "accept: application/json" -H  "Authorization: Bearer $token" -H  "content-type: application/json" -d "{\"name\":\"db\",\"parent_id\": \"$db_id\"}" | jq -r .id)
}

function remove_collections_2() {

	echo "$GREEN" "Removing /mobile, /payments, /db, /db/payments, and /db/mobile collections" "$NORMAL"
	token=$(curl -sk -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" https://${UCP}/auth/login | jq -r .auth_token) > /dev/null 2>&1
	curl -skX DELETE "https://${UCP}/collections/$db_payments_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
	curl -skX DELETE "https://${UCP}/collections/$db_mobile_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
	curl -skX DELETE "https://${UCP}/collections/$mobile_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
	curl -skX DELETE "https://${UCP}/collections/$payments_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"
	curl -skX DELETE "https://${UCP}/collections/$db_id" -H  "accept: application/json" -H  "Authorization: Bearer $token"

}




