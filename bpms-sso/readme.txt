To obtain a token from command line:

export TKN=$(curl -X POST 'http://172.17.42.6:8080/auth/realms/kieserver/protocol/openid-connect/token' \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=user1" \
 -d 'password=user' \
 -d 'grant_type=password' \
 -d 'client_id=curl' | jq -r '.access_token')

To execute a REST command:

curl -X GET 'http://172.17.42.10:8080/kie-server/services/rest/server/containers' \
-H "Accept: application/json" \
-H "Authorization: Bearer $TKN" | jq .