use Net::DBus;
use Proc::ProcessTable;
use threads;
use Thread::Queue;
our $TQWinID = Thread::Queue->new();

sub CheckDPMS {
    my $DPMSPhrase = "DPMS is";
    my $state =
      ( qx|xset q \| grep "$DPMSPhrase" | =~ s/^\s+$DPMSPhrase\s+//r );
    chomp $state;
    return $state eq "Enabled";
}

sub ProjLoop {
    $regex     = qr/(libflash)|(vlc)|(mplayer)/;
    $DPMSstate = &CheckDPMS;
    my @processes;

    while ( $TQWinID->pending() ) {
        my $winid = $TQWinID->dequeue();
    }
    @processes = ();
    foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
        if ( $_->cmndline =~ /$regex/ ) {
            push @processes, $_->pid;
        }
    }
    
    if ( ( qx#xprop -id $winid _NET_WM_PID# =~ s/[^\d]+//r ) ~~ @processes ) {
    
        print "here\n" ;
        next
          if qx|xprop -id $winid _NET_WM_STATE| !~ /_NET_WM_STATE_FULLSCREEN/;

        system $OFF;
    }
    else {
        system $ON if $DPMSstate;
    }

}

sub XWinID {
    open XPROP, 'xprop -spy -root _NET_ACTIVE_WINDOW |';
    while (<XPROP>) {
        my $winid = s/.*?\# (.*)/$1/r;
        chomp $winid;
        $TQWinID->enqueue($winid);
    }
}

threads->create( \&XWinID )->detach();
&ProjLoop();
