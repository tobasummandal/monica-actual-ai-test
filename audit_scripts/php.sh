#!/bin/bash
# Wrapper: run any PHP/composer/artisan command in a throwaway Docker container.
# Usage:
#   ./audit_scripts/php.sh artisan migrate:status
#   ./audit_scripts/php.sh php -l app/Models/Vault.php
#   ./audit_scripts/php.sh composer require some/package
exec docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(pwd):/var/www/html" \
  -w /var/www/html \
  laravelsail/php83-composer:latest \
  "$@"
