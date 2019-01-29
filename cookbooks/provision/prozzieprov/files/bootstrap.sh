#!/bin/bash

chef-solo --no-color -c /usr/local/etc/prozzie/ami/chef_conf/solo.rb -j /usr/local/etc/prozzie/ami/chef_conf/node.json
