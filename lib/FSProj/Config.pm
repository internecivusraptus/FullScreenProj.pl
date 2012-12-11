package FSProj::Config;

use 5.14.0;
our $VERSION = 0.8;

our $selfpath;

sub Init {
    $selfpath = shift;
}

sub conffile {
    return
      eval("require File::HomeDir;  File::HomeDir::my_home();")
      . "/.config/FullscreenProj.pl/fsproj.conf";
}

sub readconf {
    my $thissets = shift;
    my $config   = &conffile;
    if ( -e $config ) {
        open CONFIG, $config;
        while (<CONFIG>) {
            chomp;
            next if s/^(#.*|\s*)$//;
            my ( $var, $value ) = split( /\s*=\s*/, $_, 2 );
            ${$thissets}->{$var} = $value;
        }
        close CONFIG;
    }
    else {
        mkdir $config =~ s/fsproj.conf//gr;
        require File::Copy;
        &File::Copy::cp( $selfpath . "/share/doc/fullscreenprojpl/fsproj.conf",
            $config );
        &readconf($thissets);
    }
}

sub writeconf {
    my $thissets = shift;
    open CONFIG, ">", &conffile;
    foreach ( keys %${$thissets} ) {
        print CONFIG $_ . " = " . ${$thissets}->{$_} . "\n";
    }
    close CONFIG;
}

sub FSProcHandle {
    my ( $aproc, $dproc, $retval ) = @_;
    my %unproc   = ();
    my @currproc = ();
    require FSProj::Utils;
    &FSProj::Utils::regexp2array( $retval, \@currproc );
    foreach ( @currproc, @$aproc ) {
        $unproc{$_} = 1;
    }
    delete $unproc{$_} foreach (@$dproc);
    @$aproc = sort keys %unproc;
    &FSProj::Utils::array2regexp( $aproc, $retval );
}

sub FSPlist {
    my ( $regex, $fregex ) = @_;
    local $\ = "\n";
    print "We are currently tracking such processes:";
    {
        my @proc;
        require FSProj::Utils;
        &FSProj::Utils::regexp2array( \$fregex, \@proc );

        foreach (@proc) {
            local $\ = undef;
            local $\ = "\n" if m/$regex/;
            print "fullscreen only -> " unless m/$regex/;
            local $\ = "\n";
            print;
        }
    }
    exit;
}

sub ARGVparse {
    require Getopt::Long;
    my $thissets = shift;
    my %tempsets;
    my $action;
    my ( @dprocs, @dfprocs ) = qw/start status restart stop/;
    @dfprocs = @dprocs;
    my ( @aprocs, @afprocs );
    &readconf($thissets);
    Getopt::Long::GetOptions(
        \%tempsets,
        'timeout=i',
        'gui!',
        'fullscreen!',
        'add-proc=s{,}'  => \@aprocs,
        'rm-proc=s{,}'   => \@dprocs,
        'afdd-proc=s{,}' => \@afprocs,
        'rfm-proc=s{,}'  => \@dfprocs,
        'help'           => sub {
            require Pod::Usage;
            &Pod::Usage::pod2usage(
                -verbose  => 99,
                -sections => "NAME|SYNOPSIS|OPTIONS|ARGUMENTS"
            );
        },
        'process-list' =>
          sub { &FSPlist( ${$thissets}->{regex}, ${$thissets}->{fregex} ); },
        'version' => sub {
            print "FullScreenProj.pl version: " . $VERSION . "\n";
            exit;
        },

    );
    my @thisproc = ();
    require FSProj::Utils;
    &FSProj::Utils::processlist( qr/perl.*fsproj/, \@thisproc );
    given (@ARGV) {

        when ( "stop"    ~~ \@ARGV ) { $action = "stop"; }
        when ( "status"  ~~ \@ARGV ) { $action = "status"; }
        when ( "start"   ~~ \@ARGV ) { $action = "start"; }
        when ( "restart" ~~ \@ARGV ) { $action = "restart"; }
        default { $action = "restart"; }
    }
    if ($#thisproc) {

        foreach my $pid (@thisproc) {
            if ( $$ != $pid ) {
                given ($action) {
                    when (undef) { }
                    when (/(^start)|(status)/) {

                        print "fsproj is already running.\n";
                        print "More help: fsproj --help\n" if $_ eq "status";
                        exit;
                    }
                    when (/stop/) {
                        &FSProj::Utils::ActionHandle( 'KILL', $pid );
                        exit;
                    }
                    when (/restart/) {
                        &FSProj::Utils::ActionHandle( 'KILL', $pid );
                    }
                }
            }
        }
    }
    else {
        given ($action) {
            when (undef) { }
            when (/(stop)|(status)/) {
                print "fsproj is not running yet.\n";
                exit;
            }
        }
    }
    foreach ( keys %tempsets ) {
        ${$thissets}->{$_} = $tempsets{$_};
    }
    &FSProcHandle( \@aprocs, \@dprocs, \${$thissets}->{regex} )
      if @aprocs
          or @dprocs;
    &FSProcHandle( \@afprocs, \@dfprocs, \${$thissets}->{fregex} )
      if @afprocs
          or @dfprocs;
    &writeconf( ${thissets} ) unless $action eq "stop";
}

1;
