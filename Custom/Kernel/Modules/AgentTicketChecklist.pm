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

our @ObjectDependencies = qw(
    Kernel::Output::HTML::Layout
    Kernel::System::Ticket
    Kernel::System::PerlServices::TicketChecklist
    Kernel::System::PerlServices::TicketChecklistStatus
);

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    $Self->{Config}->{Permission} = 'rw';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject    = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $ChecklistObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklist');
    my $StatusObject    = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistStatus');

    my $Output;

    if ( $Self->{Subaction} && $Self->{Subaction} ne 'NewItem' ) {

        # check needed stuff
        if ( !$Self->{TicketID} ) {
    
            # error page
            return $LayoutObject->ErrorScreen(
                Message => 'No TicketID is given!',
                Comment => 'Please contact the admin.',
            );
        }
    
        # check permissions
        if (
            !$TicketObject->TicketPermission(
                Type     => $Self->{Config}->{Permission},
                TicketID => $Self->{TicketID},
                UserID   => $Self->{UserID}
            )
            )
        {
    
            # error screen, don't show ticket
            return $LayoutObject->NoPermission(
                Message    => "You need $Self->{Config}->{Permission} permissions!",
                WithHeader => 'yes',
            );
        }
    
        # get ACL restrictions
        $TicketObject->TicketAcl(
            Data          => '-',
            TicketID      => $Self->{TicketID},
            ReturnType    => 'Action',
            ReturnSubType => '-',
            UserID        => $Self->{UserID},
        );
        my %AclAction = $TicketObject->TicketAclActionData();
    
        # check if ACL restrictions exist
        if ( IsHashRefWithData( \%AclAction ) ) {
    
            # show error screen if ACL prohibits this action
            if ( defined $AclAction{ $Self->{Action} } && $AclAction{ $Self->{Action} } eq '0' ) {
                return $LayoutObject->NoPermission( WithHeader => 'yes' );
            }
        }
    }

    if ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my %Error;

        my @Positions = map{
            my ($Position) = $_ =~ m{(\d+)};
            $Position ? $Position : ();
        }
        grep{
            $_ =~ m{\A ItemTitle_ [0-9]+ \z}xms;
        } $ParamObject->GetParamNames();

        my @ChecklistItems;

        for my $Pos ( @Positions ) {
            my $Title = $ParamObject->GetParam( Param => 'ItemTitle_' . $Pos );
            my $State = $ParamObject->GetParam( Param => 'ItemStatus_' . $Pos );
            my $ID    = $ParamObject->GetParam( Param => 'ItemID_' . $Pos );

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
            my $Title = $ParamObject->GetParam( Param => 'ItemTitle_' . $Pos );
            my $State = $ParamObject->GetParam( Param => 'ItemStatus_' . $Pos );
            my $ID    = $ParamObject->GetParam( Param => 'ItemID_' . $Pos );

            next POS if !$Title;

            my %Opts;
            my $Method = 'TicketChecklistAdd';
            if ( $ID ) {
                $Method   = 'TicketChecklistUpdate';
                $Opts{ID} = $ID;
            }

            $ChecklistObject->$Method(
                %Opts,
                Title    => $Title,
                StatusID => $State,
                TicketID => $TicketID,
                Position => $Counter++,
                UserID   => $Self->{UserID},
            );
        }

        # redirect
        return $LayoutObject->PopupClose(
            URL => "Action=AgentTicketZoom;TicketID=$Self->{TicketID}",
        );
    }

    # new item
    elsif ( $Self->{Subaction} eq 'NewItem' ) {
        my $Position     = $ParamObject->GetParam( Param => 'Position' );
        my %StatusList   = $StatusObject->TicketChecklistStatusList();
        my $DefaultValue = $ConfigObject->Get( 'TicketChecklist::DefaultState' ) || 'open';

        my $StatusDropDown = $LayoutObject->BuildSelectionJSON([
            {
                Name          => 'ItemStatus_' . ++$Position,
                Data          => \%StatusList,
                Translation   => 1,
                SelectedValue => $DefaultValue,
            }
        ]);

        my $JSON = sprintf '{ "Status":%s, "Position":%s }', $StatusDropDown, $Position;

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # delete item
    elsif ( $Self->{Subaction} eq 'Delete' ) {
        my $ID = $ParamObject->GetParam( Param => 'ID' );

        $ChecklistObject->TicketChecklistDelete(
            ID => $ID,
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => '{"Success":1}',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # set new status
    elsif ( $Self->{Subaction} eq 'UpdateItemStatus' ) {
        my $ID = $ParamObject->GetParam( Param => 'ID' );

        my %Item = $ChecklistObject->TicketChecklistGet(
            ID => $ID,
        );

        delete $Item{Status};
        $Item{StatusID} = $ParamObject->GetParam( Param => 'StatusID' );

        my %Status = $StatusObject->TicketChecklistStatusGet( ID => $Item{StatusID} );

        $ChecklistObject->TicketChecklistUpdate(
            %Item,
            UserID => $Self->{UserID},
        );

        my $Pos  = $ParamObject->GetParam( Param => 'ItemPosition' );
        my $JSON = sprintf '{"Position":"%s", "Color":"%s"}',
            $Pos,
            $Status{Color},
        ;

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # show form
    else {
        my @ChecklistItems = $ChecklistObject->TicketChecklistTicketGet(
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

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $StatusObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistStatus');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my %StatusList = $StatusObject->TicketChecklistStatusList();

    my $Counter = 1;
    for my $Item ( @{ $Param{Items} || [] } ) {
        $Item->{Position}     = $Counter++;
        $Item->{StatusSelect} = $LayoutObject->BuildSelection(
            Name        => 'ItemStatus_' . $Item->{Position},
            Data        => \%StatusList,
            SelectedID  => $Item->{StatusID},
            Translation => 1,
        );

        $LayoutObject->Block(
            Name => 'Item',
            Data => $Item,
        );
    }

    my $Output;

    # print header
    $Output .= $LayoutObject->Header(
        Type => 'Small',
    );

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentTicketChecklist',
        Data         => {
            %Ticket,
            %Param,
            Position => $Counter-1,
        },
    );

    $Output .= $LayoutObject->Footer(
        Type => 'Small',
    );

    return $Output;
}

1;
