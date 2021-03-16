#! /usr/bin/env bash
#
# Runs docker-compose with all necessary env vars
#
# Example:
#   ./compose.sh up

# We have to set Docker user group to the same GUID as current user's group so Docker Volume will work.
# For that we pass USER_GROUP to `docker-compose` and use the group for the containers user.
export USER_GROUP="$(id -g)"

docker-compose "$@"
