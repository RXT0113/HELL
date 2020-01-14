#!/bin/sh
# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under GPL-3 license (https://www.gnu.org/licenses/gpl-3.0.en.html) in 2020

# In case end-user doesn't want bans to be in affect
[ -z "$HELL_UNBAN_ALL" ] && return 0

# Ban 'echo'
[ -z "$HELL_UNBAN_ECHO" ] && echo() {
	die 1 "Command 'echo' is banned, use 'printf' instead since echo is not standardized and will behave differently on different systems (https://askubuntu.com/a/467756) - Use 'HELL_UNBAN_ECHO' variable set on non-zero to unban" ;}

# Ban 'cd'
[ -z "$HELL_UNBAN_CD" ] && cd() {
	die 1 "Command 'cd' is banned, do not use cd in scripts if you need to perform action in required path, for commands use `--directory` argument to avoid unexpected due to the changed directory - Use 'HELL_UNBAN_CD' variable set on non-zero to unban" ;}