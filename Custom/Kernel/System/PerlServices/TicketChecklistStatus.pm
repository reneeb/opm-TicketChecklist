# --
# Kernel/System/PerlServices/TicketChecklistStatus.pm - All ticket checklist item status related functions should be here eventually
# Copyright (C) 2014 Perl-Services.de, http://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PerlServices::TicketChecklistStatus;

use strict;
use warnings;

use Kernel::System::User;
use Kernel::System::Valid;

=head1 NAME

Kernel::System::PerlServices::TicketChecklistStatus - ...

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
    use Kernel::System::PerlServices::TicketChecklistStatus;

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
    my $TicketChecklistStatusObject = Kernel::System::PerlServices::TicketChecklistStatus->new(
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
    $Self->{UserObject}  = Kernel::System::User->new( %{$Self} );
    $Self->{ValidObject} = Kernel::System::Valid->new( %{$Self} );

    return $Self;
}

=item TicketChecklistStatusAdd()

Add status

    my $ID = $TicketChecklistStatusObject->TicketChecklistStatusAdd(
        Name    => 'Ticket',
        Color   => 1235,
        ValidID => 1,
        UserID  => 123,
    );

=cut

sub TicketChecklistStatusAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(Name Color ValidID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $CheckID = $Self->TicketChecklistStatusLookup(
        Name => $Param{Name},
    );

    if ( $CheckID ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "State name alread in use",
        );

        return;
    }

    # insert state
    return if !$Self->{DBObject}->Do(
        SQL => 'INSERT INTO ps_ticketchecklist_status '
            . '(name, color, valid_id, create_time, create_by, change_time, change_by) '
            . 'VALUES (?, ?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Param{Name},
            \$Param{Color},
            \$Param{ValidID},
            \$Param{UserID},
            \$Param{UserID},
        ],
    );

    my $ID = $Self->TicketChecklistStatusLookup(
        Name => $Param{Name},
    );

    # log notice
    $Self->{LogObject}->Log(
        Priority => 'notice',
        Message  => "TicketChecklistStatus '$ID' created successfully ($Param{UserID})!",
    );

    return $ID;
}


=item TicketChecklistStatusUpdate()

to update state 

    my $Success = $TicketChecklistStatusObject->TicketChecklistStatusUpdate(
        ID            => 3,
        Name         => 1984756823,
        Color          => 1984756823,
        ValidID       => 1,
        AgentID       => 15,
        UserID        => 123,
    );

=cut

sub TicketChecklistStatusUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(ID Name Color ValidID UserID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $CheckID = $Self->TicketChecklistStatusLookup(
        Name => $Param{Name},
    );

    if ( $CheckID && $CheckID != $Param{ID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "State name alread in use",
        );
    }

    # update state
    return if !$Self->{DBObject}->Do(
        SQL => 'UPDATE ps_ticketchecklist_status SET '
            . ' name = ?, color = ?, valid_id = ?, change_time = current_timestamp, change_by = ? '
            . ' WHERE id = ?',
        Bind => [
            \$Param{Name},
            \$Param{Color},
            \$Param{ValidID},
            \$Param{UserID},
            \$Param{ID},
        ],
    );

    return 1;
}

=item TicketChecklistStatusGet()

returns a hash with status data

    my %TicketChecklistStatusData = $TicketChecklistStatusObject->TicketChecklistStatusGet( ID => 2 );

This returns something like:

    %TicketChecklistStatusData = (
        ID         => 3,
        Name       => 'closed',
        Color      => 'gray',
        ValidID    => 1,
        CreateBy   => 354,
        CreateTime => '',
        ChangeBy   => 35,
        ChangeTime => '',
    );

=cut

sub TicketChecklistStatusGet {
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
        SQL => 'SELECT id, name, color, valid_id, create_by, create_time, change_by, change_time '
            . 'FROM ps_ticketchecklist_status WHERE id = ?',
        Bind  => [ \$Param{ID} ],
        Limit => 1,
    );

    my %TicketChecklistStatus;
    while ( my @Data = $Self->{DBObject}->FetchrowArray() ) {
        %TicketChecklistStatus = (
            ID         => $Data[0],
            Name       => $Data[1],
            Color      => $Data[2],
            ValidID    => $Data[3],
            CreateBy   => $Data[4],
            CreateTime => $Data[5],
            ChangeBy   => $Data[6],
            ChangeTime => $Data[7],
        );
    }

    $TicketChecklistStatus{Valid}   = $Self->{ValidObject}->ValidLookup( ValidID => $TicketChecklistStatus{ValidID} );
    $TicketChecklistStatus{Creator} = $Self->{UserObject}->UserLookup( UserID => $TicketChecklistStatus{CreateBy} );

    return %TicketChecklistStatus;
}

=item TicketChecklistStatusDelete()

deletes a status entry. Returns 1 if it was successful, undef otherwise.

    my $Success = $TicketChecklistStatusObject->TicketChecklistStatusDelete(
        ID => 123,
    );

=cut

sub TicketChecklistStatusDelete {
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
        SQL  => 'DELETE FROM ps_ticketchecklist_status WHERE id = ?',
        Bind => [ \$Param{ID} ],
    );
}

=item TicketChecklistStatusList()

=cut

sub TicketChecklistStatusList {
    my ($Self, %Param) = @_;

    my $SQL = 'SELECT id, name FROM ps_ticketchecklist_status';

    return if !$Self->{DBObject}->Prepare(
        SQL => $SQL,
    );

    my %StatusList;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $StatusList{ $Row[0] } = $Row[1];
    }

    return %StatusList;
}

=item TicketChecklistStatusLookup()

    my $Name = $TicketChecklistStatusObject->TicketChecklistStatusLookup(
        ID => 123,
    );

or

    my $ID = $TicketChecklistStatusObject->TicketChecklistStatusLookup(
        Name => 123,
    );

=cut

sub TicketChecklistStatusLookup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} && !$Param{Name}) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need either ID or Name!',
        );
        return;
    }

    my $SQL  = 'SELECT id FROM ps_ticketchecklist_status WHERE name = ?';
    my $Bind = [ \$Param{Name} ];

    if ( $Param{ID} ) {
        $SQL  = 'SELECT name FROM ps_ticketchecklist_status WHERE id = ?';
        $Bind = [ \$Param{ID} ];
    }

    return if !$Self->{DBObject}->Prepare(
        SQL   => $SQL,
        Bind  => $Bind,
        Limit => 1,
    );

    my $Value;
    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Value = $Row[0];
    }

    return $Value;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

