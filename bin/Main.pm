use warnings;
use strict;
use threads;
use Thread::Queue;
our $TQ  = Thread::Queue->new;
our $TGQ = Thread::Queue->new;
our ( $regex, $timeout );

package FSProj;
use File::HomeDir;

my $home     = &home();
my $conffile = "$home/.config/FullscreenProj.pl/fsproj.conf";

use POSIX ('setsid');

sub readconf {
    my $switch_state;
    if ( -e $conffile ) {
        do $conffile;
        $TGQ->enqueue(1) if $switch_state;
    }
    else {
        $regex        = qr/(libflash)|(vlc)|(mplayer)/;
        $timeout      = 50;
        $switch_state = 1;
        &writeconf;
    }
}

sub writeconf {
    mkdir $conffile =~ s/fsproj.conf//r;
    open CONFIG, ">", $conffile;
    print CONFIG '$regex = ' . "\"" 
      . $regex . "\";\n"
      . '$timeout = '
      . $timeout . ";\n"
      . '$switch_state = '
      . $TGQ->pending() . ";\n";
    close CONFIG;

}

sub daemonize {
    die "Can't chdir to /: $!" unless chdir '/';
    umask 0;
    die "Can't read /dev/null: $!"     unless open STDIN,  '/dev/null';
    die "Can't write to /dev/null: $!" unless open STDOUT, '>/dev/null';
    die "Can't write to /dev/null: $!" unless open STDERR, '>/dev/null';
    die "Can't fork: $!" unless defined( my $pid = fork );
    exit if $pid;
    die "Can't start a new session: $!" unless setsid();
    sleep 1;

    foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
        if ( ( $_->cmndline =~ /perl.*fsproj/ ) and ( $_->pid != $$ ) ) {
            die 'Another instance is running';
        }
    }

}

#&daemonize;

&readconf;
#threads->create(&FSLogic::ScreenSaver)->detach;

#threads->create( FSGUI->new()->MainLoop )->detach;
#&FSLogic::main;
1;
