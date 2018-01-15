#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

set -x

export IMAGE_ROOT="$PWD/image-root"

mkdir -p /sys/fs/cgroup
mountpoint -q /sys/fs/cgroup || \
  mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup

# Setup special cgroups that can't be taken directly from /proc/cgroups
mkdir -p /sys/fs/cgroup/cpu,cpuacct
mount -n -t cgroup -o cpu,cpuacct cpu,cpuacct /sys/fs/cgroup/cpu,cpuacct
mkdir -p /sys/fs/cgroup/net_cls,net_prio
mount -n -t cgroup -o net_cls,net_prio net_cls,net_prio /sys/fs/cgroup/net_cls,net_prio
mkdir -p /sys/fs/cgroup/systemd
mount -t cgroup cgroup -o none,name=systemd /sys/fs/cgroup/systemd

sed -e '1d;s/\([^\t]\)\t.*$/\1/' < /proc/cgroups | egrep -v ^cpu$\|^cpuacct$\|^net_cls$\|^net_prio$ | while IFS= read -r d; do
  mkdir -p "/sys/fs/cgroup/$d"
  mountpoint -q "/sys/fs/cgroup/$d" || \
    mount -n -t cgroup -o "$d" "$d" "/sys/fs/cgroup/$d" || \
    :
done

# We currently assume we can put the graph in /tmp/build/graph; in our
# configuration, that's btrfs and the subvolumes will get cleaned up correctly
# the concourse removes the volume.
mkdir -p /tmp/build/graph
dockerd -g /tmp/build/graph --mtu 1432 &

until docker info >/dev/null 2>&1; do
  echo waiting for docker to come up...
  sleep 1
done
