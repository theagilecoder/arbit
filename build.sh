#!/usr/bin/env bash
# Script for building a MIX release of a Phoenix app

set -e

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest

# Custom tasks (like DB migrations)
MIX_ENV=prod mix ecto.migrate

# Remove the existing release directory & build the release
rm -rf "_build"
MIX_ENV=prod mix release