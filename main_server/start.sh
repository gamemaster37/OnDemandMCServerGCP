#!/bin/bash

./latest_paper.sh

exec java -Xmx3500M -Xms1000M -jar server.jar nogui