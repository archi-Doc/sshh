#!/usr/bin/expect -f

set password "abcd"
spawn su -
expect "Password:"
send "$password\r"
interact
