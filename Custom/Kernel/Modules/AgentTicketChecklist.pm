# --
# Kernel/Modules/AgentTicketChecklist.pm - manage the checklist for a ticket
# Copyright (C) 2014 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketChecklist;

use strict;
use warnings;

use Kernel::System::PerlServices::TicketChecklist;
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check needed Objects
    for my $Needed (qw(ParamObject DBObject TicketObject LayoutObject LogObject ConfigObject)) {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    $Self->{ChecklistObject} = Kernel::System::PerlServices::TicketChecklist->new(%Param);

    $Self->{Config}->{Permission} = 'rw';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;

    # check needed stuff
    if ( !$Self->{TicketID} ) {

        # error page
        return $Self->{LayoutObject}->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check permissions
    if (
        !$Self->{TicketObject}->TicketPermission(
            Type     => $Self->{Config}->{Permission},
            TicketID => $Self->{TicketID},
            UserID   => $Self->{UserID}
        )
        )
    {

        # error screen, don't show ticket
        return $Self->{LayoutObject}->NoPermission(
            Message    => "You need $Self->{Config}->{Permission} permissions!",
            WithHeader => 'yes',
        );
    }

    # get ACL restrictions
    $Self->{TicketObject}->TicketAcl(
        Data          => '-',
        TicketID      => $Self->{TicketID},
        ReturnType    => 'Action',
        ReturnSubType => '-',
        UserID        => $Self->{UserID},
    );
    my %AclAction = $Self->{TicketObject}->TicketAclActionData();

    # check if ACL restrictions exist
    if ( IsHashRefWithData( \%AclAction ) ) {

        # show error screen if ACL prohibits this action
        if ( defined $AclAction{ $Self->{Action} } && $AclAction{ $Self->{Action} } eq '0' ) {
            return $Self->{LayoutObject}->NoPermission( WithHeader => 'yes' );
        }
    }

    if ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my %Error;

        # check needed data
        if ( !$Param{ChecklistUserID} ) {
            $Error{'ChecklistUserIDInvalid'} = 'ServerError';
        }
        if ( !$Param{ChecklistID} ) {
            $Error{'ChecklistIDInvalid'} = 'ServerError';
        }

        if (%Error) {
            return $Self->Form( { %Param, %Error } );
        }


        # redirect
        return $Self->{LayoutObject}->PopupClose(
            URL => "Action=AgentTicketZoom;TicketID=$Self->{TicketID}",
        );
    }

    # new item
    if ( $Self->{Subaction} eq 'AJAXUpdate' ) {
    }

    # show form
    else {
        return $Self->Form(%Param);
    }
}

sub Form {
    my ( $Self, %Param ) = @_;

    my $Output;

    # print header
    $Output .= $Self->{LayoutObject}->Header(
        Type => 'Small',
    );

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentTicketChecklist',
        Data         => \%Param,
    );

    $Output .= $Self->{LayoutObject}->Footer(
        Type => 'Small',
    );

    return $Output;
}

1;
