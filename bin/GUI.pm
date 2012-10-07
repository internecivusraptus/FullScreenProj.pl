package FSSettingsDialog;

use Wx qw[:everything];
use base qw(Wx::Dialog);

sub new {
    my ( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent = undef             unless defined $parent;
    $id     = -1                unless defined $id;
    $title  = ""                unless defined $title;
    $pos    = wxDefaultPosition unless defined $pos;
    $size = [ 220, 122 ];
    $name = "" unless defined $name;
    $style = wxDEFAULT_DIALOG_STYLE;
    $self =
      $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
    $self->{fsenable} = Wx::CheckBox->new(
        $self, -1,
        "      Fullscreen processing\n      right after start",
        [ 27, 10 ],
    );
    $self->{tmlabel} =
      Wx::StaticText->new( $self, -1, "Timeout in seconds", [ 76, 60 ], );
    $self->{timeout} = Wx::SpinCtrl->new(
        $self, -1, "",
        [ 10, 56 ],
        [ 55, 20 ],
        wxSP_ARROW_KEYS, 0, 100, 100
    );
    $self->{btn_Ok}     = Wx::Button->new( $self, -1, "Ok",     [ 17,  85 ] );
    $self->{btn_Cancel} = Wx::Button->new( $self, -1, "Cancel", [ 119, 85 ] );
    $self->SetTitle("Settings");

    return $self;

}

1;

package FSGUI;

use Wx;
use Cwd;
use Thread::Queue;
use base 'Wx::App';
our ( $ID_SETTINGS, $ID_EXIT ) = ( 1001, 1010 );

our $TGQ = Thread::Queue->new;

sub OnExit {
    $self = shift;
    $self->{stdlg}->Destroy();
    $self->{tbi}->Destroy();
    $self->{tbicon}->Destroy();
    $self->{popmenu}->Destroy();

    #  my $self->Destroy;
}

sub OnInit {
    my $self = shift;

    my $state = 1 || $TGQ->pending();
    my $tip;
    $self->{stdlg}   = FSSettingsDialog->new();
    $self->{tbi}     = Wx::TaskBarIcon->new();
    $self->{tbicon}  = Wx::Icon->new();
    $self->{popmenu} = Wx::Menu->new();
    $self->OnSwState($state);
    $self->{stdlg}->Show;

    $self->MenuGen($state);
    $self->{tbi}->Connect(
        -1, -1,
        &Wx::wxEVT_TASKBAR_LEFT_DOWN,
        sub {
            $state = !$state;
            $self->OnSwState($state);
        }
    );
    $self->{tbi}->Connect( -1, -1, &Wx::wxEVT_TASKBAR_RIGHT_DOWN,
        sub { $self->{tbi}->PopupMenu( $self->{popmenu} ); } );
    return 1;
}

sub OnSwState {
    my ( $this, $state ) = @_;
    my $path = ( Cwd::getcwd =~ s/(.*)\/.*/$1/r );
    $path .= "/icons/fsproj";
    $tip = $state ? "Enabled" : "Disabled";
    $this->{tbicon}->LoadFile( "$path/$tip.xpm", &Wx::wxBITMAP_TYPE_XPM );

    $state ? $TGQ->enqueue(1) : $TGQ->dequeue;
    $this->{tbi}->SetIcon( $this->{tbicon}, $tip );
}

sub MenuGen {
    my ( $this, $state ) = @_;
    $this->{popmenu}->Append( $ID_SETTINGS, "Settings..." );
    $this->{popmenu}->AppendSeparator();
    $this->{popmenu}->Append( $ID_EXIT, "Exit\tCtrl-X" );
    $this->{popmenu}->Connect(
        $ID_EXIT, -1,
        &Wx::wxEVT_COMMAND_MENU_SELECTED,
        sub {
            $this->ExitMainLoop();
        }
    );
    $this->{popmenu}->Connect(
        $ID_SETTINGS,
        -1,
        &Wx::wxEVT_COMMAND_MENU_SELECTED,
        sub {
            $this->{stdlg}->Show;
        }
    );
}

1;
1;
