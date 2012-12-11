use strict;
use warnings;

package FSProj::GUI::AddProcessDialog;

use Wx qw[:everything];
use base qw(Wx::Dialog);
use strict;

sub new {
    my ( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent = undef             unless defined $parent;
    $id     = -1                unless defined $id;
    $title  = ""                unless defined $title;
    $pos    = wxDefaultPosition unless defined $pos;
    $size = [ 330, 150 ];
    $name = "" unless defined $name;

    $style = wxDEFAULT_DIALOG_STYLE
      unless defined $style;

    $self =
      $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
    $self->SetTitle("Add process dialog");
    $self->{stupidlabel} =
      Wx::StaticText->new( $self, -1, "Enter process name" );
    $self->{txt_prname} = Wx::TextCtrl->new( $self, -1, "" );
    $self->{btn_gap} = Wx::Button->new( $self, -1, "Get application process" );
    $self->{btn_gap}->Connect(
        -1, -1,
        &Wx::wxEVT_COMMAND_BUTTON_CLICKED,
        sub {
            open my $fh, "-|", "xprop", "_NET_WM_PID";
            chomp( my $pid = <$fh> =~ s/[^\d+]//gr );
            require Proc::ProcessTable;
            return unless $pid;
            foreach ( reverse @{ 'Proc::ProcessTable'->new->table } ) {
                if ( $_->pid == $pid ) {
                    $self->{txt_prname}->SetValue( ($_->cmndline=~s/(.*?) .*/$1/gr)=~s/\/.*\/(.*)/$1/gr );
                    last;
                }

            }
        }
    );
    $self->{btn_Cancel} = Wx::Button->new( $self, wxID_CANCEL, "" );
    $self->{btn_OK}     = Wx::Button->new( $self, wxID_OK,     "" );
    $self->doLayout();
    return $self;

}

sub GetValue {
    my $this = shift;
    return $this->{txt_prname}->GetValue;
}

sub doLayout {
    my $self = shift;

    $self->{frame}   = Wx::BoxSizer->new(wxVERTICAL);
    $self->{sizer_3} = Wx::BoxSizer->new(wxHORIZONTAL);
    $self->{frame}->Add( $self->{stupidlabel}, 0, wxALL | wxEXPAND, 5 );
    $self->{frame}->Add( $self->{txt_prname},  0, wxALL | wxEXPAND, 5 );
    $self->{frame}
      ->Add( $self->{btn_gap}, 0, wxALL | wxEXPAND | wxALIGN_BOTTOM, 5 );
    $self->{frame}->Add( Wx::StaticLine->new( $self, -1 ), 0, wxEXPAND, 0 );

    $self->{sizer_3}->Add( 0, 0, 8, wxALIGN_LEFT | wxEXPAND, 5 );
    $self->{sizer_3}->Add( $self->{btn_Cancel}, 5, wxALL, 5 );
    $self->{sizer_3}->Add( $self->{btn_OK},     5, wxALL, 5 );
    $self->{frame}->Add( $self->{sizer_3}, 0, wxEXPAND, 0 );
    $self->SetSizer( $self->{frame} );
    $self->{frame}->Fit($self);
    $self->Layout();
}
sub SetValue {
    my $this = shift;
    $this->{txt_prname}->SetValue(shift);
}
1;

package FSProj::GUI::SettingsDialog;

use Wx qw[:everything];
use base qw(Wx::Dialog);

sub new {
    my ( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent = undef             unless defined $parent;
    $id     = -1                unless defined $id;
    $title  = ""                unless defined $title;
    $pos    = wxDefaultPosition unless defined $pos;
    $size = [ 420, 265 ];
    $name = "" unless defined $name;
    $style = wxDEFAULT_DIALOG_STYLE;
    $self =
      $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
    $self->{fsfs} =
      Wx::CheckBox->new( $self, -1, "Only fullscreen apps", [ 27, 110 ], );
    $self->{fsgui} =
      Wx::CheckBox->new( $self, -1, "Use WxWidgets GUI.", [ 27, 140 ], );
    $self->{fsgui}->Connect(
        -1, -1,
        &Wx::wxEVT_COMMAND_CHECKBOX_CLICKED,
        sub {
            Wx::MessageBox('This change will take effect after restart')
              unless $self->{fsgui}->GetValue;
        }
    );
    $self->{tmlabel} =
      Wx::StaticText->new( $self, -1, "Timeout in seconds", [ 76, 183 ], );
    $self->{timeout} = Wx::SpinCtrl->new(
        $self, -1, "",
        [ 10, 181 ],
        [ 55, 20 ],
        wxSP_ARROW_KEYS, 1, 100
    );
    $self->{fsprchecklist} =
      Wx::CheckListBox->new( $self, -1, [ 210, 0 ], [ 200, 160 ], );
    $self->{adddialog} = FSProj::GUI::AddProcessDialog->new($self);

    $self->{btn_add} = Wx::Button->new( $self, wxID_ADD, "", [ 217, 170 ] );
    
    $self->{btn_add}->Connect(
        -1, -1,
        &Wx::wxEVT_COMMAND_BUTTON_CLICKED,
        sub {
            $self->{adddialog}->SetValue("");
            if ( $self->{adddialog}->ShowModal == wxID_OK ) {
                 $self->{fsprchecklist}->Append( [ $self->{adddialog}->GetValue ] )
                  unless ( $self->{fsprchecklist}
                    ->FindString( $self->{adddialog}->GetValue ) > -1 );
            }
        }
    );

    $self->{btn_del} = Wx::Button->new( $self, wxID_DELETE, "", [ 319, 170 ] );
    $self->{btn_del}->Connect(
        -1, -1,
        &Wx::wxEVT_COMMAND_BUTTON_CLICKED,
        sub {
            $self->{fsprchecklist}
              ->Delete( $self->{fsprchecklist}->GetSelection );
        }
    );
    Wx::StaticLine->new( $self, -1, [203, 0], [10,210 ], wxLI_VERTICAL);    
    Wx::StaticLine->new( $self, -1, [2, 208], [416,10 ] ),    
    $self->{btn_Ok} = Wx::Button->new( $self, wxID_OK, "", [ 132, 220 ] );
    $self->{btn_Cancel} =
      Wx::Button->new( $self, wxID_CANCEL, "", [ 234, 220 ] );
    $self->SetTitle("Settings");
    return $self;
}

sub ContentGenerator {
    my ( $self, $settings ) = @_;
    $self->{fsfs}->SetValue( ${$settings}->{fullscreen} );
    $self->{fsgui}->SetValue( ${$settings}->{gui} );
    $self->{timeout}->SetValue( ${$settings}->{timeout} );
    my @processes;
    &FSProj::Utils::regexp2array( \${$settings}->{fregex}, \@processes );
    foreach ( 0 .. $#processes ) {
        my $fsonly = ( $processes[$_] !~ m/${$settings}->{regex}/ );
        $self->{fsprchecklist}->Append( [ $processes[$_] ] );
        $self->{fsprchecklist}->Check( $_, $fsonly );
    }

}

1;

package FSProj::GUI::App;

use Wx;
use base 'Wx::App';

sub OnInit {

    my $self = shift;
    require FSProj::Logic;
    require FSProj::Config;
    $self->{settings} = pop @ARGV;
    threads->create( \&FSProj::Logic::XWinID )->detach;
    threads->create( \&FSProj::Logic::ProjLoop, $self->{settings} )->detach;
    $self->{stdlg}    = FSProj::GUI::SettingsDialog->new();
    $self->{stdlg}->ContentGenerator( $self->{settings} );
    $self->{tbi}     = Wx::TaskBarIcon->new();
    $self->{popmenu} = Wx::Menu->new();
    $self->{tbi}->SetIcon(
        Wx::Icon->new(
            "$FSProj::Config::selfpath/share/icons/fsproj/Disabled.xpm",
            &Wx::wxBITMAP_TYPE_XPM
        ),
        "FullScreenProj.pl"
    );
    $self->MenuGen;
    $self->{tbi}->Connect(
        -1, -1,
        &Wx::wxEVT_TASKBAR_LEFT_DOWN,
        sub {

        }
    );
    $self->{tbi}->Connect( -1, -1, &Wx::wxEVT_TASKBAR_RIGHT_DOWN,
        sub { $self->{tbi}->PopupMenu( $self->{popmenu} ); } );
    return $self;
}

sub MenuGen {
    my $this = shift;
    $this->{popmenu}->Append( &Wx::wxID_PROPERTIES, "" );
    $this->{popmenu}->AppendSeparator();
    $this->{popmenu}->Append( &Wx::wxID_ABOUT, "" );
    $this->{popmenu}->AppendSeparator();
    $this->{popmenu}->Append( &Wx::wxID_EXIT, "" );
    $this->{popmenu}->Connect(
        &Wx::wxID_EXIT,
        -1,
        &Wx::wxEVT_COMMAND_MENU_SELECTED,
        sub {
            &FSProj::Utils::ActionHandle( 'KILL', $$ );
            &Wx::wxExit;
        }

    );
    $this->{popmenu}->Connect(
        &Wx::wxID_ABOUT,
        -1,
        &Wx::wxEVT_COMMAND_MENU_SELECTED,
        sub {
            my $abdialog = Wx::AboutDialogInfo->new();
            $abdialog->SetName("FullScreenProj.pl");
            $abdialog->SetVersion("$FSProj::Config::VERSION");
            $abdialog->SetDescription(
                "Crazy Fullscreen Detector & Screensaver Disabler");
            $abdialog->SetCopyright(
                '©2012, Igor Gritsenko <xenomorph@mail.univ.kiev.ua>');
            $abdialog->SetWebSite( "http://github/drone-pl/FullScreenProj.pl",
                "GitHub Repository" );
            $abdialog->SetDevelopers( [ 'Igor Gritsenko', 'Dmitry Perlow' ] );
            Wx::AboutBox($abdialog);
        }
    );

    $this->{popmenu}->Connect(
        &Wx::wxID_PROPERTIES,
        -1,
        &Wx::wxEVT_COMMAND_MENU_SELECTED,
        sub {
            if ( $this->{stdlg}->ShowModal == &Wx::wxID_OK ) {
                ${ $this->{settings} }->{timeout} =
                  $this->{stdlg}->{timeout}->GetValue;
                ${ $this->{settings} }->{gui} =
                  $this->{stdlg}->{fsgui}->GetValue;
                ${ $this->{settings} }->{fullscreen} =
                  $this->{stdlg}->{fsfs}->GetValue;
                my @list  = ();
                my @flist = ();
                for (
                    my $i = 0 ;
                    $i < $this->{stdlg}->{fsprchecklist}->GetCount ;
                    $i++
                  )
                {
                    push @flist, $this->{stdlg}->{fsprchecklist}->GetString($i);
                    push @list,  $this->{stdlg}->{fsprchecklist}->GetString($i)
                      unless $this->{stdlg}->{fsprchecklist}->IsChecked($i);
                }

                &FSProj::Utils::array2regexp( \@list,
                    \${ $this->{settings} }->{regex} );
                &FSProj::Utils::array2regexp( \@flist,
                    \${ $this->{settings} }->{fregex} );
                &FSProj::Config::writeconf($this->{settings} );
            }

        }
    );
}

1;
