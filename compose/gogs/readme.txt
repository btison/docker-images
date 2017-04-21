Gogs Curl commands

* create user

$ read -r -d '' _DATA_JSON << EOM
{
    "login_name": "developer",
    "username": "developer",
    "email": "developer@example.com",
    "password": "developer"
}
EOM
$ curl -X POST -H "Content-Type: application/json" -u gogsadmin:admin123 -d "$_DATA_JSON" "http://gogs-gogs-1.gogs.docker:3000/api/v1/admin/users"

* create organization

$ curl -X POST -H "Content-Type: application/json" -u gogsadmin:admin123 -d '{"username":"team"}' "http://gogs-gogs-1.gogs.docker:3000/api/v1/admin/users/developer/orgs"

* Import repository

$ TEAM_ID=$(curl -X GET -u gogsadmin:admin123 http://gogs-gogs-1.gogs.docker:3000/api/v1/user/orgs | grep -o '"id":[0-9]*,' | grep -o [0-9]*)
$ read -r -d '' _DATA_JSON << EOM
{
  "clone_addr": "https://github.com/gpe-mw-training/appdev-foundations-kitchensink.git",
  "uid": $TEAM_ID,
  "repo_name": "kitchensink"
}
EOM
$ curl -H "Content-Type: application/json" -d "$_DATA_JSON" -u gogsadmin:admin123 -X POST http://gogs-gogs-1.gogs.docker:3000/api/v1/repos/migrate