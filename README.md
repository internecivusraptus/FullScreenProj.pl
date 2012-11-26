h1. NAME

fsproj - Crazy Fullscreen Detector & Screensaver Disabler

h1. SYNOPSIS

fsproj [options] <action>

Actions:

*start stop restart status*

Options:

*[--help] [--no-gui] [--gui] [--timeout seconds] [--disable] [--enable] [--process-list] [--add-proc process] [--del-proc process]*

Use --help for more information.

h1. OPTIONS

- *--help* := Verbose description of command line options.

- *--no-gui* := Do not use the GUI (Default).

- *--gui* := Enable WxWidgets GUI.

- *--timeout seconds* := Set timeout in seconds.

- *--disable* := Start inactive script.

- *--enable* := Start script and activate it (Default).

- *--process-list* := Show current tracking process list.

- *--add-proc process* := Add process for tracking.

- *--del-proc process* := Delete process from tracking.

h1. ARGUMENTS

- *start* := Starts the script and sets the specified options.

- *stop* := Stops the script. All options will be ignored.

- *status* := Shows current status of the script.

- *restart* := Restarts the script.

Any other arguments will be ignored.

h1. DESCRIPTION

_FullScreenProj.pl_ a.k.a _fsproj_ is a small utility that detects various videoplayers in fullscreen mode and allows users to disable screensaver and/or screen power off via DPMS. Users can control its behaviour via command line.

Default timeout is set to 50 seconds, default process list includes vlc, mplayer, and flash plugin. Settings that were changed via command line, are saved in config file, thus they could be used for further usage. See "EXAMPLES" for more info.

h1. EXAMPLES

- @fsproj@ := Runs brief help and exit.

- @fsproj start@ := Starts the utility with previous configuration.

- @fsproj stop@ := Stops the utility.

- @fsproj --timeout 10 start@ := Starts the utility with changed timeout and saves this timeout to config.

- @fsproj --add-proc totem --del-proc mplayer vlc restart@ := Restarts the utility, removing mplayer and vlc from tracking list and adding totem to it. All changes are saved to config.

- @fsproj --gui start@ := Add WxWidgets GUI for easy use by novice users. Implemented, but bugged and not currently integrated in utility.

- @fsproj --process-list@ := Shows info about currently tracked processes and exits.

h1. AUTHOR

Igor Gritsenko <xenomorph@mail.univ.kiev.ua>

h1. COPYRIGHT

Copyright (c) 2012 Igor Gritsenko <xenomorph@mail.univ.kiev.ua>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

