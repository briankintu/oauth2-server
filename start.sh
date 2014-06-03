#!/bin/bash

export NODE_CONFIG_DIR=${NODE_CONFIG_DIR:=config}
NODE_ENV=${NODE_ENV:=development}
if [ -n "$1" ]; then
    NODE_ENV=$1
fi
export NODE_ENV

echo "Environment: $NODE_ENV"

function startf(){
    APP=$1
    PIDFILE=$APP.pid

    if [ -e $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        if [ -z "$PID" ]; then
            echo "Cleaning up empty PID file $PIDFILE" >&2
            rm -f $PIDFILE
        elif pmap "$PID" | grep -q nodejs; then
            echo "Not starting $APP, running PID $PID" >&2
            return 1
        else
            echo "Process $PID no longer running; deleting $PIDFILE" >&2
            rm -f $PIDFILE
        fi
    fi
    echo "node $APP" >&2
    node $APP
}

startf ./dummy-servers/MemStore-server.js # this is a no-op unless "MemStore" is a configured storage type.
startf ./dummy-servers/resource-server.js # this is a no-op unless resource_server.type is "dummy"
startf ./src/server.js
exit 0