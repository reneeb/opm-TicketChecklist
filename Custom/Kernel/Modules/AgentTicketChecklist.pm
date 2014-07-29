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
use Kernel::System::PerlServices::TicketChecklistStatus;
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
    $Self->{StatusObject}    = Kernel::System::PerlServices::TicketChecklistStatus->new(%Param);

    $Self->{Config}->{Permission} = 'rw';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;

    if ( $Self->{Subaction} && $Self->{Subaction} ne 'NewItem' ) {

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
    }

    if ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $Self->{LayoutObject}->ChallengeTokenCheck();

        my %Error;

        my @Positions = map{
            my ($Position) = $_ =~ m{(\d+)};
            $Position ? $Position : ();
        }
        grep{
            $_ =~ m{\A ItemTitle_ [0-9]+ \z}xms;
        } $Self->{ParamObject}->GetParamNames();

        my @ChecklistItems;

        for my $Pos ( @Positions ) {
            my $Title = $Self->{ParamObject}->GetParam( Param => 'ItemTitle_' . $Pos );
            my $State = $Self->{ParamObject}->GetParam( Param => 'ItemStatus_' . $Pos );
            my $ID    = $Self->{ParamObject}->GetParam( Param => 'ItemID_' . $Pos );

            push @ChecklistItems, +{
                StateID  => $State,
                ID       => $ID,
                Title    => $Title,
                Position => $Pos,
            };

            if ( !defined $Title ) {
                $Error{ 'ItemTitle_' . $Pos } = 'ServerError';
            }

            if ( !defined $State ) {
                $Error{ 'ItemStatus_' . $Pos } = 'ServerError';
            }
        }

        # check needed data
        if (%Error) {
            return $Self->Form(
                %Param,
                %Error,
                Items => \@ChecklistItems,
            );
        }

        my $TicketID = $Self->{TicketID};

        my $Counter = 1;

        POS:
        for my $Pos ( sort { $a <=> $b }@Positions ) {
            my $Title = $Self->{ParamObject}->GetParam( Param => 'ItemTitle_' . $Pos );
            my $State = $Self->{ParamObject}->GetParam( Param => 'ItemStatus_' . $Pos );
            my $ID    = $Self->{ParamObject}->GetParam( Param => 'ItemID_' . $Pos );

            next POS if !$Title;

            my %Opts;
            my $Method = 'TicketChecklistAdd';
            if ( $ID ) {
                $Method   = 'TicketChecklistUpdate';
                $Opts{ID} = $ID;
            }

            $Self->{ChecklistObject}->$Method(
                %Opts,
                Title    => $Title,
                StatusID => $State,
                TicketID => $TicketID,
                Position => $Counter++,
                UserID   => $Self->{UserID},
            );
        }

        # redirect
        return $Self->{LayoutObject}->PopupClose(
            URL => "Action=AgentTicketZoom;TicketID=$Self->{TicketID}",
        );
    }

    # new item
    elsif ( $Self->{Subaction} eq 'NewItem' ) {
        my $Position     = $Self->{ParamObject}->GetParam( Param => 'Position' );
        my %StatusList   = $Self->{StatusObject}->TicketChecklistStatusList();
        my $DefaultValue = $Self->{ConfigObject}->Get( 'TicketChecklist::DefaultState' ) || 'open';

        my $StatusDropDown = $Self->{LayoutObject}->BuildSelectionJSON([
            {
                Name          => 'ItemStatus_' . ++$Position,
                Data          => \%StatusList,
                Translation   => 1,
                SelectedValue => $DefaultValue,
            }
        ]);

        my $JSON = sprintf '{ "Status":%s, "Position":%s }', $StatusDropDown, $Position;

        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # delete item
    elsif ( $Self->{Subaction} eq 'Delete' ) {
        my $ID = $Self->{ParamObject}->GetParam( Param => 'ID' );

        $Self->{ChecklistObject}->TicketChecklistDelete(
            ID => $ID,
        );

        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => '{"Success":1}',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # set new status
    elsif ( $Self->{Subaction} eq 'UpdateItemStatus' ) {
        my $ID = $Self->{ParamObject}->GetParam( Param => 'ID' );

        my %Item = $Self->{ChecklistObject}->TicketChecklistGet(
            ID => $ID,
        );

        delete $Item{Status};
        $Item{StatusID} = $Self->{ParamObject}->GetParam( Param => 'StatusID' );

        my %Status = $Self->{StatusObject}->TicketChecklistStatusGet( ID => $Item{StatusID} );

        $Self->{ChecklistObject}->TicketChecklistUpdate(
            %Item,
            UserID => $Self->{UserID},
        );

        my $Pos  = $Self->{ParamObject}->GetParam( Param => 'ItemPosition' );
        my $JSON = sprintf '{"Position":"%s", "Color":"%s"}',
            $Pos,
            $Status{Color},
        ;

        return $Self->{LayoutObject}->Attachment(
            ContentType => 'application/json; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # show form
    else {
        my @ChecklistItems = $Self->{ChecklistObject}->TicketChecklistTicketGet(
            TicketID => $Self->{TicketID},
        );

        return $Self->Form(
            %Param,
            Items => \@ChecklistItems,
        );
    }
}

sub Form {
    my ( $Self, %Param ) = @_;

    my %StatusList = $Self->{StatusObject}->TicketChecklistStatusList();

    my $Counter = 1;
    for my $Item ( @{ $Param{Items} || [] } ) {
        $Item->{Position}     = $Counter++;
        $Item->{StatusSelect} = $Self->{LayoutObject}->BuildSelection(
            Name        => 'ItemStatus_' . $Item->{Position},
            Data        => \%StatusList,
            SelectedID  => $Item->{StatusID},
            Translation => 1,
        );

        $Self->{LayoutObject}->Block(
            Name => 'Item',
            Data => $Item,
        );
    }

    my $Output;

    # print header
    $Output .= $Self->{LayoutObject}->Header(
        Type => 'Small',
    );

    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'AgentTicketChecklist',
        Data         => {
            %Ticket,
            %Param,
            Position => $Counter-1,
        },
    );

    $Output .= $Self->{LayoutObject}->Footer(
        Type => 'Small',
    );

    return $Output;
}

1;
