#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import re
import yaml

# Use environment variables directly
envVars = os.environ

inputYamlFile = sys.argv[1]
outputYamlFile = sys.argv[2]
externalListenHosts = envVars.get('EXTERNAL_LISTEN_HOSTS', '').split()
externalListenHost = envVars.get('EXTERNAL_LISTEN_HOST', None)
if externalListenHost and externalListenHost not in externalListenHosts:
    externalListenHosts.append(externalListenHost)

print(f"DEBUG: externalListenHosts={externalListenHosts}")
print(f"DEBUG: externalListenHost={externalListenHost}")
listenHosts = list()
for host in externalListenHosts:
    if host not in listenHosts:
        listenHosts.append(host)

print(f"DEBUG: listenHosts={listenHosts}")

# read input yaml file
with open(inputYamlFile, 'r') as file:
    config = yaml.load(file, Loader=yaml.Loader)

# processing addresses for nodes
for index, nodes in enumerate(config.get('nodes', [])):  # Use .get() to avoid KeyError
    if not nodes.get('addresses') or not nodes['addresses']:
        print(f"WARNING: No addresses found for node {index}")
        continue
    try:
        listenHost = nodes['addresses'][0].split(':')[0]
        listenPort = nodes['addresses'][0].split(':')[1] if ':' in nodes['addresses'][0] else '1001'  # Default port if missing
        nodeListenHosts = [listenHost] + listenHosts
        for nodeListenHost in nodeListenHosts:
            listenAddress = f"{nodeListenHost}:{listenPort}"
            if listenAddress not in nodes['addresses']:
                nodes['addresses'].append(listenAddress)
            # add "quic" listen address
            for name, value in envVars.items():
                if re.match(r"^(ANY_SYNC_.*_PORT)$", name) and value == listenPort:
                    if re.match(r"^(ANY_SYNC_.*_QUIC_PORT)$", name):
                        continue
                    quicPortKey = name.replace('_PORT', '_QUIC_PORT')
                    quicPortValue = envVars.get(quicPortKey)
                    quicListenAddress = f'quic://{nodeListenHost}:{quicPortValue}'
                    if quicPortValue and quicListenAddress not in nodes['addresses']:
                        nodes['addresses'].append(quicListenAddress)
    except IndexError as e:
        print(f"ERROR: Invalid address format for node {index}: {nodes['addresses']}")
        continue

# write output yaml file
with open(outputYamlFile, 'w') as file:
    yaml.dump(config, file)