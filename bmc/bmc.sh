#!/bin/bash

set -ex

# First argument should be a command
COMMAND=$1

if [ -z "$COMMAND" ]; then
  echo "Usage: $0 attach|detach"
  exit 1
fi

IFACE="enp3s0f1s0"  # Change this to your interface

case "$COMMAND" in
  attach)
    echo "Attaching BMC on interface $IFACE"

    # Attach TC hook
    sudo tc qdisc add dev $IFACE clsact
    sudo tc filter add dev $IFACE egress bpf object-pinned /sys/fs/bpf/bmc_tx_filter

    echo "BMC attached successfully."
    ;;
  detach)
    echo "Detaching BMC from interface $IFACE"
    # Detach TC hook
    sudo tc filter del dev $IFACE egress
    sudo tc qdisc del dev $IFACE clsact
    sudo rm -f /sys/fs/bpf/bmc_tx_filter
    ;;
  *)
    echo "Invalid command. Usage: $0 attach|detach"
    exit 1
    ;;
esac
