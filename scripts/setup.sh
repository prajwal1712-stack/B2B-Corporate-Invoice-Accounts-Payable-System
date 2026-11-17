#!/usr/bin/env bash
# Builds the database and prints the KPI reports.  Usage: ./scripts/setup.sh [mysql-user]
set -e
USER_=${1:-root}
mysql -u"$USER_" -p < sql/01_schema.sql
mysql -u"$USER_" -p < sql/02_sample_data.sql
mysql -u"$USER_" -p -t < sql/03_analytics_and_tests.sql
