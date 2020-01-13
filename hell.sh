#!/bin/sh
# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under GPL-3 lisense (https://www.gnu.org/licenses/gpl-3.0.en.html) in 2019.
# Based in part upon 'before-install' from rsplib	(https://raw.githubusercontent.com/dreibh/rsplib/master/ci/before-install), which is:
#    Copyright (C) 2018-2019 by Thomas Dreibholz <dreibh@iem.uni-due.de> as GPLv3 or any other GPL at your option

# NOT_PRODUCTION_READY
printf 'WARN: %s\n' "This file is not production ready, USE ON YOUR OWN RISK!"

: '
Frontend for HELL

HOW TO USE
- FIXME: info needed
'

# Capture arguments
while [ $# -ge 1 ]; do case "$1" in
	--run)
		# Source backend
		find -path "$(pwd)/backend" -name '*.sh' -name '*.bash' -exec "sh -c \"{}\" \;"

		# Run HELL
		# shellcheck disable=SC2044 # HOTFIX!
		for file in "$(find . -not \( \
			-path './.git' -prune -o \
			-path './vendor' -prune -o \
			-name 'LICENSE' -prune -o \
			-name '.gitignore' -prune -o \
			-name 'os-release' -prune -o \
			-name '.keepinfodir' -prune -o \
			-path './build' -prune -o \
			-path './target' -prune -o \
			-name 'lock' -prune \
		\) -type f)"; do

			# Identify file
			## Check for extension
			case "$file" in
				*.c) identifier="C" ;;
				*.sh) identifier="shell" ;;
				*.bash) identifier="bash" ;;
				*.yml) identifier="yaml" ;;
				*.md) identifier="markdown" ;;
				*.png) identifier="png" ;;
				*.zsh) identifier="zsh" ;;
				*.conf) identifier="config" ;;
				*.fish) identifier="fish" ;;
				*.gpg) identifier="gpg" ;;
				*.service) identifier="service" ;;
				*.donotcheck|*.disabled) identifier="DoNotCheck" ;;
				*.json) identifier="json" ;;
				*.Dockerfile) identifier="dockerfile" ;;
				*.xml) identifier="xml" ;;
				*.fetchnext) identifier="fetchnext" ;;
				*/Makefile) identifier="makefile" ;;
				*.bak) identifier="backup" ;;
				*.vmdb) identifier="vmdb" ;;
				*[a-Z]*) # Check for shebang
					edebug "Checking shebang of '$file'"

					case "$(head -n1 "$file")" in
						'#!/'*'/bash'|'#!/'*' bash') identifier="bash" ;;
						'#!/'*'/sh'|'#!/'*' sh') identifier="shell" ;;
						'#compdef'*) identifier="zsh" ;;
						'#!/'*) die fixme "File '$file' has unsupported shebang '$(head -n1 "$file")'" ;;
						*) # Check through 'file' command
							edebug "Checking file '$file' through 'file' command"
							if command -v file >/dev/null; then
								case "$(file "$file")" in
									*) die 1 "File '$file' was not recognized through extension shebang and through 'file' command, fixme"
								esac
							elif ! command -v file >/dev/null; then
								die 1 "Unable to identify file '$file' through extension nor shebeng and command 'file' is not executable, fixme?"
							else
								die 255 "Checking file '$file' through 'file' command"
							fi
					esac ;;
				*) die 1 "Unable to identify file '$file'"
			esac

			# Output message about checked file
			if [ -z "$HELL_CUSTOM_CHECKING_MESSAGE" ]; then
				printf "checking $identifier file %s\\n" "${file#./}"
			elif [ -n "$HELL_CUSTOM_CHECKING_MESSAGE" ]; then
				"$HELL_CUSTOM_CHECKING_MESSAGE"
			else
				die 255 "outputing a message about checking with  HELL_CUSTOM_CHECKING_MESSAGE set on '$HELL_CUSTOM_CHECKING_MESSAGE'"
			fi

			# Test file based on identifier
			case "$identifier" in
				C)
					cppcheck --error-exitcode=1 "$file" || die lintfail ;;
				yaml|config|service|json|xml|dockerfile)
					fixme LintNotImplemented ;;
				markdown)
					npx markdownlint --config QA/markdownlint.json "$file" || die lintfail ;;
				gpg)
					fixme "Checking for gpg file is stub, skipping.." ; true

					created="$(cat "$file" | gpg --list-packets | grep -o "sig created[^)]\{1,\})" -m 1)"
					created="${created##sig created }"
					created="${created%)}"

					year="${created%%-??-??}"
					month="${created##????-}"
					month="${created%%-??}"

					day="${created##????-??-}"

					expires="$(cat "$file" | gpg --list-packets | grep -o "expires after[^)]\{1,\})")"
					expires="${expires##expires after }"
					expires="${expires%%)}"

					expires="$(cat "$file" | gpg --list-packets | grep -o "expires after[^)]\{1,\})")" ; expires="${expires##expires after }" ; expires="${expires%%)}"

					expires_year="$(print '%s\n' "$expires" | grep -o "[^y]\{1,\}y")"
					expires_year="${expires_year%%y}"
				;;
				makefile)
					fixme "Check if checkmake is installed"
					fixme "Check if host has internet connecting for checkmake version checking"
					if curl https://api.github.com/repos/mrtazz/checkmake/tags 2>/dev/null | grep -qF '"name": "1.0.0",'; then
						checkmake "$file" || die lintfail
					elif ! curl https://api.github.com/repos/mrtazz/checkmake/tags 2>/dev/null | grep -qF '"name": "1.0.0",'; then
						printf 'WARN: %s\n' "Command 'checkmake' used for linting is still in development, this is a stub implementation untill version 1.0.0 is released, skipping fatal assuming not reliable enough"
						checkmake "$file" || true
					else
						printf 'FATAL: %s\n' "Unexpected happend in check.sh while linting makefile"
					fi
				;;
				backup|png|vmdb)
					true # Do not check these
				;;
				DoNotCheck)
					einfo "File $file is set to be ignored by tests by extension"
				;;
				fetchnext)
					ewarn "fetchnext files are stub"
				;;
				bash)
					shellcheck -x -s bash "$file" || die lintfail
				;;
				shell)
					shellcheck -x -s shell "$file" || die lintfail
				;;
				zsh)
					fixme "zsh are apparently tested agains bash in shellcheck (sanity-check required)"
					shellcheck -x -s bash "$file" || die lintfail
				;;
				fish)
					fixme LintNotImplemented
				;;
				*) die 255 "Unknown identifier for file '$file' has been parsed, unable to resolve.."
			esac
		done ;;
	--help|-help|-h|help)
		printf '%s\n' \
			"FIXME: help-page needed" ;;
	*)
		# Do not use 'die' here in case it wasn't sourced properly
		printf 'FATAL: %s\n' "Argument '$1' is not supported"
		exit 2 # exit-code for syntax error
esac; done