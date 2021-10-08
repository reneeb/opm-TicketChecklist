# --
# Copyright (C) 2020 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::CustomerTicketChecklist;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::System::Ticket
    Kernel::System::Log
    Kernel::System::Main
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
    Kernel::Config
    Kernel::System::User
    Kernel::System::PerlServices::TicketChecklist
    Kernel::System::PerlServices::TicketChecklistTicketInfo
    Kernel::System::PerlServices::TicketChecklistStatus
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject      = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChecklistObject  = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklist');
    my $TicketInfoObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistTicketInfo');
    my $StatusObject     = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistStatus');
    my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject     = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject     = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');

    # define if rich text should be used
    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );

    if ( !$TicketID ) {
        my ($TicketNumber) = $ParamObject->GetParam( Param => 'TicketNumber' );
        $TicketID          = $TicketObject->TicketIDLookup(
            TicketNumber => $TicketNumber,
            UserID       => $Self->{UserID} // $LayoutObject->{UserID},
        );
    }

    return 1 if !$TicketID;

    $Self->{UserID} //= $LayoutObject->{UserID};

    my %Info = $TicketInfoObject->GetInfo(
        TicketID => $TicketID,
    );

    return 1 if !%Info;
    return 1 if !$Info{CustomerVisibility};


    my @ChecklistItems = $ChecklistObject->TicketChecklistTicketGet(
        TicketID => $TicketID,
    );

    return 1 if !@ChecklistItems;

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $TicketID,
        UserID   => $Self->{UserID},
    );

    my %StatusList   = $StatusObject->TicketChecklistStatusList();
    my %StatusColors;

    for my $StatusID ( keys %StatusList ) {
        my %StatusInfo = $StatusObject->TicketChecklistStatusGet(
            ID => $StatusID,
        );

        $StatusColors{$StatusID} = $StatusInfo{Color};
    }

    my $ItemsShown = 0;

    ITEM:
    for my $Item ( @ChecklistItems ) {
        $ItemsShown++;

        $Item->{StatusSelect} = sprintf "(%s)", $LayoutObject->{LanguageObject}->Translate( $StatusList{ $Item->{StatusID} } );

        $Item->{ResponsibleID}  //= 0;
        $Item->{ResponsibleKey} //= '';

        $Item->{Color} = $StatusColors{ $Item->{StatusID} };

        $LayoutObject->Block(
            Name => 'Item',
            Data => $Item,
        );
    }

    return 1 if !$ItemsShown;

    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'CustomerTicketChecklistWidget',
    );

    ${$Param{Data}} =~ s{(<div\s+id="FollowUp")}{$Snippet $1}xms;

    return 1;
}

1;
