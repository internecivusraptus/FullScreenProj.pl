package Logic;
use Net::DBus;
use Proc::ProcessTable;
$| = 1;
my $ON  = 'xset +dpms';
my $OFF = 'xset -dpms';

sub ScreenSaver {
    my $command;
    foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
        if ( $_->cmndline =~ /xscreensaver/ ) {
            $command = qq(system "xscreensaver-command -deactivate");
        }

        elsif ( $_->cmndline =~ /krunner/ ) {
            $command =
qq(Net::DBus->session->get_service("org.freedesktop.ScreenSaver")->get_object('/ScreenSaver')->SimulateUserActivity());
        }

        elsif ( $_->cmndline =~ /gnome-screensaver/ ) {
            $command =
qq(Net::DBus->session->get_service("org.gnome.ScreenSaver")->get_object('/')->SimulateUserActivity());
        }
    }
    return sub {
        while (1) {
            my $timeout=$settings{timeout};
            if ( $TQScrSvr->pending ) {
                $timeout=$TQScrSvr->peek();
                eval $command;
                if ($@) { warn $@; }
            }
            print $timeout;
            sleep $timeout;
        }
      }
}

sub CheckDPMS {
    my $DPMSPhrase = "DPMS is";
    chomp( my $state =
          ( qx|xset q \| grep "$DPMSPhrase" | =~ s/^\s+$DPMSPhrase\s+//r ) );
    return $state eq "Enabled";
}

sub ProjLoop {
    my $DPMSstate = &CheckDPMS;
    my @processes;
    while (1) {
        my ($winid) = $TQWinID->peek;
        while ( $TQWinID->pending() ) {
            $TQWinID->dequeue();
        }

        while ( !$TQWinID->pending() ) {

            @processes = ();
            foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
                if ( $_->cmndline =~ /$settings{regex}/ ) {
                    push @processes, $_->pid;
                }
            }
            if ( ( qx#xprop -id $winid _NET_WM_PID# =~ s/[^\d]+//r ) ~~
                @processes
                and qx|xprop -id $winid _NET_WM_STATE| =~
                /_NET_WM_STATE_FULLSCREEN/ )
            {
                $TQScrSvr->enqueue( $settings{timeout} );
                system $OFF;
            }
            else {
                while ( $TQScrSvr->pending() ) {
                    $TQScrSvr->dequeue();
                }

                system $ON if $DPMSstate;
            }
            sleep $settings{timeout};
        }
    }
    close XPROP;
}

sub XWinID {
    open XPROP, 'xprop -spy -root _NET_ACTIVE_WINDOW |';
    while (<XPROP>) {
        my $winid = s/.*?\# (.*)/$1/r;
        chomp $winid;
        $TQWinID->enqueue($winid);
    }
}

1;
