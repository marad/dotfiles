This repository contains configurations for user environment.
It has setup for personal Linux-based machine and work related MacOS.
When making changes ensure that:

- all changes are introduced in a reproducible way (so that install.sh would make it work on new machine)
- both personal and work setup are the same
- Follow YAGNI principles, and one-liner solutions
- when introducing changes remember that there are multiple machines (linux and macos based) that will need updating. Plan for easy migration.
- do not add email to .gitconfig, the `install.sh` script does this when installing so that the email can be different on different machines
