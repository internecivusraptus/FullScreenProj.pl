package FSProj::Logic;

our $WinID : shared = 1;

sub ScreenSaver {
    my $command   = shift;
    my %cmnd_hash = (
        q[system "xscreensaver-command -deactivate"] => "xscreensaver",
        q[  require Net::DBus;
    Net::DBus->import;
    Net::DBus->session->get_service("org.freedesktop.ScreenSaver")->get_object('/ScreenSaver')->SimulateUserActivity()]
          => "krunner",
        q[  require Net::DBus;
    Net::DBus->import;
    Net::DBus->session->get_service("org.gnome.ScreenSaver")->get_object('/')->SimulateUserActivity()]
          => "gnome-screensaver"
    );
    while ( my ( $cmnd, $saver ) = each(%cmnd_hash) ) {
        my @array_p = ();
        &FSProj::Utils::processlist( $saver, \@array_p );
        if (@array_p) { $$command = $cmnd; last; }
    }
}

sub CheckDPMS {
    my $retval     = shift;
    my $DPMSPhrase = "DPMS is";
    chomp( my $state =
          qx|xset q \| grep "$DPMSPhrase" | =~ s/^\s+$DPMSPhrase\s+//gr );
    $$retval = $state eq "Enabled";
}

sub ProjLoop {
    my $thissets = shift;
    my $ScrSvr;
    &FSProj::Logic::ScreenSaver( \$ScrSvr );
    my $ON  = 'xset +dpms';
    my $OFF = 'xset -dpms';
    my $DPMSstate;
    &CheckDPMS( \$DPMSstate );
    my @processes;
    my @fprocesses;
    my $winid;

    while ($WinID) {
        {
            lock $WinID;
            $winid = $WinID;
            $WinID = 0;
        }
        &FSProj::Utils::processlist( ${$thissets}->{regex},  \@processes );
        &FSProj::Utils::processlist( ${$thissets}->{fregex}, \@fprocesses );
        until ($WinID) {
            if (
                (
                    ${$thissets}->{fullscreen}
                    and qx#xprop -id $winid _NET_WM_PID# =~ s/[^\d]+//gr ~~
                    \@fprocesses
                    and qx|xprop -id $winid _NET_WM_STATE| =~
                    /_NET_WM_STATE_FULLSCREEN/
                )
                or qx!xprop -id $winid _NET_WM_PID! =~ s/[^\d]+//gr ~~
                \@processes
              )
            {
                if ($ScrSvr) {
                    eval $ScrSvr;
                    if ($@) {
                        warn $@;
                    }
                }
                system $OFF;
            }
            else {
                system $ON if $DPMSstate;
            }
            sleep ${$thissets}->{timeout};
        }
    }
    threads->detach;
    threads->exit;
}

sub XWinID {
    open XPROP, 'xprop -spy -root _NET_ACTIVE_WINDOW |';
    my $winid_p = -1;
    while (<XPROP>) {
        {
            chomp( my $winid = s/.*?\# (.*)/$1/gr );
            lock $WinID;
            $WinID = $winid if $winid and $winid_p ne $winid;
            $winid_p = $winid;
        }
    }
    close XPROP;
    threads->detach;
    threads->exit;
}

1;
