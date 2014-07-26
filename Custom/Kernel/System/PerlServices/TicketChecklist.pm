# --
# Kernel/System/PerlServices/TicketChecklist.pm - All TicketChecklist related functions should be here eventually
# Copyright (C) 2014 Perl-Services.de, http://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PerlServices::TicketChecklist;

use strict;
use warnings;

use Kernel::System::User;
use Kernel::System::PerlServices::TicketChecklistStatus;

=head1 NAME

Kernel::System::PerlServices::TicketChecklist - backend for ticket checklists

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::Main;
    use Kernel::System::DB;
    use Kernel::System::PerlServices::TicketChecklist;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $TicketChecklistObject = Kernel::System::PerlServices::TicketChecklist->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        EncodeObject => $EncodeObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(DBObject ConfigObject MainObject LogObject EncodeObject TimeObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    # create needed objects
    $Self->{UserObject}   = Kernel::System::User->new( %{$Self} );
    $Self->{ValidObject}  = Kernel::System::Valid->new( %{$Self} );
    $Self->{StatusObject} = Kernel::System::PerlServices::TicketChecklistStatus->new( %{$Self} );

    return $Self;
}

=item TicketChecklistAdd()

Add time tracking 

    my $ID = $TicketChecklistObject->TicketChecklistAdd(
        TicketID => 1235,
        Title    => 'tracking title', # (optional)
        Status   => 'open',  # or StatusID => 1,
        UserID   => 123,
        AgentID  => 123,
    );

=cut

sub TicketChecklistAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed ( qw(TicketID Title ValidID UserID Position) ) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    if ( !$Param{Status} && !$Param{StatusID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need either Status or StatusID',
        );

        return;
    }

    if ( $Param{Status} ) {
        $Param{StatusID} = $Self->{StatusObject}->TicketChecklistStatusLookup( Name => $Param{Status} );
    }

    my $Status = $Self->{StatusObject}->TicketChecklistStatusLookup( ID => $Param{StatusID} );
    if ( !defined $Status ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Cannot find Status for ID ' . $Param{StatusID},
        );

        return;
    }

    # insert new item
    return if !$Self->{DBObject}->Do(
        SQL => 'INSERT INTO ps_ticketchecklist '
            . '(title, position, status_id, ticket_id, '
            . ' valid_id, create_time, create_by, change_time, change_by) '
            . 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Title},
            \$Param{Position},
            \$Param{StatusID},
            \$Param{TicketID},
            \$Param{ValidID},
            \$Param{UserID},
            \$Param{UserID},
        ],
    );

    # get new item id
    return if !$Self->{DBObject}->Prepare(
        SQL   => 'SELECT MAX(id) FROM ps_ticketchecklist WHERE position = ? AND ticket_id = ?',
        Bind  => [ \$Param{Position}, \$Param{TicketID} ],
        Limit => 1,
    );

    my $ID;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $ID = $Row[0];
    }

    # log notice
    $Self->{LogObject}->Log(
        Priority => 'notice',
        Message  => "TicketChecklist item '$ID' created successfully ($Param{UserID})!",
    );

    return $ID;
}


=item TicketChecklistUpdate()

to update news 

    my $Success = $TicketChecklistObject->TicketChecklistUpdate(
        ID            => 3,
        Title         => 'A title',
        ValidID       => 1,
        UserID        => 123,
    );

=cut

sub TicketChecklistUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ID ObjectType ObjectID ValidID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # insert new news
    return if !$Self->{DBObject}->Do(
        SQL => 'UPDATE ps_time_tracking SET '
            . 'object_id = ?, object_type = ?, start = ?, stop = ?, comments = ?, '
            . 'exported = ?, edited = ?, manual = ?, valid_id = ?, user_id = ?, title = ?, '
            . 'committed = ?, change_time = current_timestamp, change_by = ? '
            . ' WHERE id = ?',
        Bind => [
            \$Param{ObjectID},
            \$Param{ObjectType},
            \$Param{Start},
            \$Param{Stop},
            \$Param{Comment},
            \$Param{Exported},
            \$Param{Edited},
            \$Param{Manual},
            \$Param{ValidID},
            \$Param{AgentID},
            \$Param{Title},
            \$Param{Committed},
            \$Param{UserID},
            \$Param{ID},
        ],
    );

    return 1;
}

=item TicketChecklistGet()

returns a hash with news data

    my %TicketChecklistData = $TicketChecklistObject->TicketChecklistGet( ID => 2 );

This returns something like:

    %TicketChecklistData = (
        ID            => 3,
        ObjectType    => 'Ticket',
        ObjectID      => 1235,
        Start         => 1984756823,
        Stop          => 1984756823,
        Comment       => 'A comment',
        Title         => 'A title',
        Exported      => 1,
        Edited        => 1,
        Manual        => 1,
        ValidID       => 1,
        AgentID       => 15,
        CreateBy      => 354,
        CreateTime    => '',
        ChangeBy      => 35,
        ChangeTime    => '',
    );

=cut

sub TicketChecklistGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # sql
    return if !$Self->{DBObject}->Prepare(
        SQL => 'SELECT id, object_type, object_id, start, stop, comments, exported, edited, manual, '
            . 'valid_id, user_id, create_by, create_time, change_by, change_time, title '
            . 'FROM ps_time_tracking WHERE id = ?',
        Bind  => [ \$Param{ID} ],
        Limit => 1,
    );

    my %TicketChecklist;
    while ( my @Data = $Self->{DBObject}->FetchrowArray() ) {
        %TicketChecklist = (
            ID            => $Data[0],
            ObjectType    => $Data[1],
            ObjectID      => $Data[2],
            Start         => $Data[3],
            Stop          => $Data[4],
            Comment       => $Data[5],
            Exported      => $Data[6],
            Edited        => $Data[7],
            Manual        => $Data[8],
            ValidID       => $Data[9],
            AgentID       => $Data[10],
            CreateBy      => $Data[11],
            CreateTime    => $Data[12],
            ChangeBy      => $Data[13],
            ChangeTime    => $Data[14],
            Title         => $Data[15],
        );
    }

    if ( $TicketChecklist{ObjectType} && $TicketChecklist{ObjectID} ) {
        my $Type = $TicketChecklist{ObjectType};
        $TicketChecklist{Title} = $Self->{ $Type . 'BackendObject' }->GetTitle(
            ObjectID => $TicketChecklist{ObjectID},
            UserID   => 1,
        );

        $TicketChecklist{Subject} = $Self->{ $Type . 'BackendObject' }->GetSubject(
            ObjectID => $TicketChecklist{ObjectID},
            UserID   => 1,
        );
    }

    $TicketChecklist{Valid}   = $Self->{ValidObject}->ValidLookup( ValidID => $TicketChecklist{ValidID} );
    $TicketChecklist{Creator} = $Self->{UserObject}->UserLookup( UserID => $TicketChecklist{CreateBy} );
    $TicketChecklist{Agent}   = $Self->{UserObject}->UserLookup( UserID => $TicketChecklist{AgentID} );

    return %TicketChecklist;
}

=item TicketChecklistDelete()

deletes a news entry. Returns 1 if it was successful, undef otherwise.

    my $Success = $TicketChecklistObject->TicketChecklistDelete(
        ID => 123,
    );

=cut

sub TicketChecklistDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    return $Self->{DBObject}->Do(
        SQL  => 'DELETE FROM ps_time_tracking WHERE id = ?',
        Bind => [ \$Param{ID} ],
    );
}

=item TicketChecklistTicketGet()

=cut

sub TicketChecklistTicketGet {
    my ($Self,%Param) = @_;

    for my $Needed ( qw(TicketID) ) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );

            return;
        }
    }

    my $SQL = 'SELECT id, title, position, status_id, valid_id, ticket_id '
        . ' FROM ps_ticketchecklist '
        . ' WHERE ticket_id = ? ';

    return if !$Self->{DBObject}->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{TicketID},
        ],
    );
}

=item TicketChecklistMerge()

=cut

sub TicketChecklistMerge {
    my ($Self, %Param) = @_;

    for my $Needed (qw(ObjectType OldObjectID NewObjectID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );

            return;
        }
    }

    my $SQL = 'UPDATE ps_time_tracking '
        . ' SET object_id = ?, change_time = current_timestamp, change_by = ? '
        . ' WHERE object_type = ? AND object_id = ?';

    return if !$Self->{DBObject}->Prepare(
        SQL  => $SQL,
        Bind => [
            \$Param{NewObjectID},
            \$Param{UserID},
            \$Param{ObjectType},
            \$Param{OldObjectID},
        ],
    );

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

