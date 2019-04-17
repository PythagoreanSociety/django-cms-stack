#!/bin/bash

cmd="$@"
echo "Runnng with args: $cmd"
set -x

until pg_isready -U postgres -h db ; do
    echo "Waiting for DB to start..."
    sleep 5
done

exec $cmd

