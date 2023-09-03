#!/usr/bin/env bash

set -e

trap "k8sage stop; exit $?" INT TERM

k8sage start

while true; do sleep 1; done
