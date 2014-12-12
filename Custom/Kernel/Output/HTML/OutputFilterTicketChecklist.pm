# --
# Kernel/Output/HTML/OutputFilterTicketChecklist.pm
# Copyright (C) 2014 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterTicketChecklist;

use strict;
use warnings;

use List::Util qw(first);

use Kernel::System::Encode;
use Kernel::System::Time;
use Kernel::System::PerlServices::TicketChecklist;
use Kernel::System::PerlServices::TicketChecklistStatus;

our $VERSION = 0.02;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(MainObject ConfigObject LogObject LayoutObject ParamObject)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{UserID} = $Param{UserID};

    $Self->{EncodeObject}    = $Param{EncodeObject} || Kernel::System::Encode->new( %{$Self} );
    $Self->{TimeObject}      = $Param{TimeObject}   || Kernel::System::Time->new( %{$Self} );

    $Self->{DBObject} = $Self->{LayoutObject}->{DBObject};

    if ( $Param{TicketObject} ) {
        $Self->{TicketObject} = $Param{TicketObject};
        $Self->{DBObject}     = $Self->{TicketObject}->{DBObject} if !$Self->{DBObject};
    }

    if ( $Self->{DBObject} ) {
        $Self->{ChecklistObject} = Kernel::System::PerlServices::TicketChecklist->new( %{$Self} );
        $Self->{StatusObject}    = Kernel::System::PerlServices::TicketChecklistStatus->new( %{$Self} );
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    #my $Templatename = $Param{TemplateFile} || '';
    my $Templatename = $Self->{ParamObject}->GetParam( Param => 'Action' );

    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};
    return 1 if !$Self->{TicketObject};

    # define if rich text should be used
    my ($TicketID) = $Self->{ParamObject}->GetParam( Param => 'TicketID' );

    return 1 if !$TicketID;

    my @ChecklistItems = $Self->{ChecklistObject}->TicketChecklistTicketGet(
        TicketID => $TicketID,
    );

    return 1 if !@ChecklistItems;

    my %StatusList   = $Self->{StatusObject}->TicketChecklistStatusList();
    my %StatusColors;

    for my $StatusID ( keys %StatusList ) {
        my %StatusInfo = $Self->{StatusObject}->TicketChecklistStatusGet(
            ID => $StatusID,
        );

        $StatusColors{$StatusID} = $StatusInfo{Color};
    }

    for my $Item ( @ChecklistItems ) {
        $Item->{StatusSelect} = $Self->{LayoutObject}->BuildSelection(
            Name        => 'ItemStatusWidget_' . $Item->{Position},
            Data        => \%StatusList,
            SelectedID  => $Item->{StatusID},
            Translation => 1,
        );

        $Item->{Color} = $StatusColors{ $Item->{StatusID} };

        $Self->{LayoutObject}->Block(
            Name => 'Item',
            Data => $Item,
        );
    }

    my $Snippet = $Self->{LayoutObject}->Output(
        TemplateFile => 'TicketChecklistWidget',
        Data         => {
            TicketID => $TicketID,
        },
    );

    my $Position = $Self->{ConfigObject}->Get( 'TicketChecklist::Position' ) || 'top';

    if ( $Position eq 'bottom' ) {
        ${ $Param{Data} } =~ s{(</div> \s+ <div \s+ class="ContentColumn)}{ $Snippet $1 }xms;
    }
    else {
        ${ $Param{Data} } =~ s{(<div \s+ class="SidebarColumn">)}{$1 $Snippet}xsm;
    }

    my $JS = $Self->{LayoutObject}->Output(
        Template => '<script type="text/javascript" src="$Config{"Frontend::JavaScriptPath"}PS.TicketChecklistWidget.js"></script>',
    );

    ${ $Param{Data} } =~ s{</body}{$JS</body};

    return ${ $Param{Data} };
}

1;
