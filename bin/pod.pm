__END__

=pod

=head1 NAME

fsproj - Crazy Fullscreen Detector & Screensaver Disabler

=head1 SYNOPSIS

fsproj [options] <action>

Actions:

B<start stop>

Options:

B<[--help] [--no-gui] [--gui] [--timeout seconds] [--disable] [--enable] [--process-list] [--add-proc process] [--del-proc process]>

Use --help for more information.

=head1 OPTIONS

=over 8

=item B<--help>

Verbose description of command line options.

=back

=over 8

=item B<--no-gui>

Do not use the GUI (Default).

=back

=over 8

=item B<--gui>

Enable WxWidgets GUI.

=back

=over 8

=item B<--timeout seconds>

Set timeout in seconds.

=back

=over 8

=item B<--disable>

Start script only, don't allow anything to do.

=back

=over 8

=item B<--enable>

Start script and let him do work (Default). 

=back

=over 8

=item B<--process-list>

Show current tracking process list.

=back

=over 8

=item B<--add-proc process>

Add process for tracking.

=back

=over 8

=item B<--del-proc process>

Delete process from tracking.

=back

=head1 ARGUMENTS

=over 8

=item B<start> 

Starts the script, if not started yet, and  sets the specified options.

=back

=over 8

=item B<stop>  

Stops the script. All options will be ignored.

=back 

Any other arguments will be ignored. If script runs without action, it saves parameters and, if running, restarts the utility.


=head1 DESCRIPTION

I<FullScreenProj.pl> a.k.a I<fsproj> - small utility that detects various videoplayers fullscreen and allows users to disable screensaver and/or screen power off via DPMS. Users can control its behaviour via command line.

Default timeout is set to 50 seconds, default process list includes vlc, mplayer, and flash plugin. 
Settings that were changed via command line, are saved in config file, thus could be used for further usage. See L</EXAMPLES> for more info.

=head1 EXAMPLES

=over 8

=item C<fsproj>

Runs brief help and exit.

=back

=over 8

=item C<fsproj start>

Starts or restarts the utility with default or saved configuration.

=back

=over 8

=item C<fsproj stop>

Stops the utility.

=back

=over 8

=item C<fsproj --timeout 10 start>

Starts or restarts the utility, with changed timeout and saves this timeout to config.

=back


=over 8

=item C<fsproj --add-proc totem --del-proc mplayer vlc start>

Starts or restarts the utility, removing mplayer and vlc from tracking list and adding totem to it. All changes are saved to config. 

=back


=over 8

=item C<fsproj --gui start>

Add WxWidgets GUI for easy use of novice users. Implemented, but bugged and not currently integrated in utility.

=back


=over 8

=item C<fsproj --process-list>

Shows info about currently tracked processes and exit. 

=back


=over 8

=item C<fsproj --disable>

Disables processing if started and saves this parameter to config file. It won't start script if it wasn't running. If script is running, this command don't stop it, it will wait until C<fsproj --enable> or C<fsproj stop>.

=back


=head1 AUTHOR

Igor Gritsenko <xenomorph@mail.univ.kiev.ua>

=head1 COPYRIGHT

Copyright (c) 2012 Igor Gritsenko <xenomorph@mail.univ.kiev.ua>

This program is free software; you can redistribute it and/or
                modify it under the same terms as Perl itself.

=cut
