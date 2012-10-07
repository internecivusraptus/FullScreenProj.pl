package FSLogic;
use Net::DBus;
use Proc::ProcessTable;
my $ON  = 'xset +dpms';
my $OFF = 'xset -dpms';

sub ScreenSaver {
    my $command;
    foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
        if ( $_->cmndline =~ /xscreensaver/ ) {
            $command = qq(system "xscreensaver-command -deactivate");
        }

        elsif ( $_->cmndline =~ /kscreensaver/ ) {
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
            if ( $TQ->pending() ) {
                eval $command;
                if ($@) { warn $@; }
            }
            sleep $timeout;
        }
      }

}

sub TestDPMS {
    my $DPMSPhrase = "DPMS is";
    my $state = (qx|xset q \| grep "$DPMSPhrase" | =~
      s/^\s+$DPMSPhrase\s+//r);
    chomp $state;
    return $state eq "Enabled";
}

sub ProjLoop { 
    $regex        = qr/(libflash)|(vlc)|(mplayer)/;
    $DPMSstate = &TestDPMS;
    my @processes;
    open XPROP, 'xprop -spy -root _NET_ACTIVE_WINDOW |';
    while (<XPROP>) {
#        if ( $TGQ->pending() ) {
            my $winid = s/.*?\# (.*)/$1/r;
            chomp $winid;
            @processes = ();
            foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
                if ( $_->cmndline =~ /$regex/ ) {
                    push @processes, $_->pid;
                }
            }

            if ( ( qx#xprop -id $winid _NET_WM_PID# =~ s/[^\d]+//r ) ~~
                @processes )
                
                {
                next
                  if qx|xprop -id $winid _NET_WM_STATE| =~
                      /_NET_WM_STATE_FULLSCREEN/;

                #while
                # and )

#                $TQ->enqueue(1);
                system $OFF if $DPMSstate;
            }
            else {
                system $ON if $DPMSstate;
#                while ( $TQ->pending() ) { $TQ->dequeue() }
            }

        }
    }
#}
&ProjLoop;
