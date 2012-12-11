package FSProj::Utils;

sub regexp2array {
    my ( $inp_reg, $retval ) = @_;
    @$retval = split( /\|/, $$inp_reg =~ s/[\(\)\:\^\?]//gr );
}

sub array2regexp {
    my ( $ref_arr, $ret_val ) = @_;
    $$ret_val = "(?^:(" . join( ')|(', @$ref_arr ) . "))";
}

sub processlist {
    require Proc::ProcessTable;
    my ( $cmndline, $retval ) = @_;
    foreach ( @{ 'Proc::ProcessTable'->new->table; } ) {
        if ( $_->cmndline =~ $cmndline ) {
            push @$retval, $_->pid;
        }
    }
}

sub daemonize {
    require POSIX;
    die "Can't chdir to /: $!" unless chdir '/';
    umask 0;
    die "Can't read /dev/null: $!"     unless open STDIN,  '/dev/null';
    die "Can't write to /dev/null: $!" unless open STDOUT, '>/dev/null';
    die "Can't write to /dev/null: $!" unless open STDERR, '>/dev/null';
    die "Can't fork: $!" unless defined( my $pid = fork );
    exit if $pid;
    die "Can't start a new session: $!" unless &POSIX::setsid();
}

sub ActionHandle {
    my ( $signal, $pid ) = @_;
    kill $signal => -$pid;
}

1;
