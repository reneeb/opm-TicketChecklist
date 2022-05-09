# --
# Kernel/System/PerlServices/TicketChecklistTicketInfo.pm 
# Copyright (C) 2020 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PerlServices::TicketChecklistTicketInfo;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::User
    Kernel::System::Log
    Kernel::System::DB
);

=head1 NAME

Kernel::System::PerlServices::TicketChecklistTicketInfo

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item DeleteInfoForTicket()

Delete all information for a ticket

=cut

sub DeleteInfoForTicket {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    for my $Needed (qw(TicketID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    return if !$DBObject->Do(
        SQL  => 'DELETE FROM ps_checklist_ticket_info WHERE ticket_id = ?',
        Bind => [ \$Param{TicketID} ],
    );

    return 1;
}

=item GetInfo()

Get all information for a ticket

=cut

sub GetInfo {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    for my $Needed (qw(TicketID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    return if !$DBObject->Prepare(
        SQL  => 'SELECT customer_visibility FROM ps_checklist_ticket_info WHERE ticket_id = ?',
        Bind => [ \$Param{TicketID} ],
    );

    my %Info;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Info{CustomerVisibility} = $Row[0];
    }

    return %Info;
}

=item SetInfo()

Add status

    my $ID = $Object->SetInfo(
        TicketID           => 123,
        CustomerVisibility => 1,
        UserID             => 123,
    );

=cut

sub SetInfo {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    my %Required;

    # check needed stuff
    for my $Needed (qw(TicketID UserID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }

        $Required{$Needed} = delete $Param{$Needed};
    }

    my $CheckID = $Self->_TicketIDCheck(
        TicketID => $Required{TicketID},
    );

    my @Columns;
    my @Binds;

    my $DoInsert = 1;
    if ( $CheckID ) {
        $DoInsert = 0;

        my %ColumnMap = (
            CustomerVisibility => 'customer_visibility',
        );

        PARAMNAME:
        for my $ParamName ( keys %Param ) {
            next PARAMNAME if !$ColumnMap{$ParamName};

            push @Columns, $ColumnMap{$ParamName} . ' = ?';
            push @Binds, \$Param{$ParamName};
        }
    }

    $Param{CustomerVisibility} // 0;

    # insert state
    return if $DoInsert && !$DBObject->Do(
        SQL => 'INSERT INTO ps_checklist_ticket_info '
            . '(ticket_id, customer_visibility, create_time, create_by, change_time, change_by) '
            . 'VALUES (?, ?, current_timestamp, ?, current_timestamp, ?)',
        Bind => [
            \$Required{TicketID},
            \$Param{CustomerVisibility},
            \$Required{UserID},
            \$Required{UserID},
        ],
    );

    return if !$DoInsert && $DBObject->Do(
        SQL => 'UPDATE ps_checklist_ticket_info '
            . 'SET ' . join(', ', @Columns) . ', change_time = current_timestamp, change_by = ?'
            . 'WHERE ticket_id = ?',
        Bind => [
            @Binds,
            \$Required{UserID},
            \$Required{TicketID},
        ],
    );

    return 1;
}


=item _TicketIDCheck()

    my $Exists = $Object->_TicketIDCheck(
        TicketID => 123,
    );

=cut

sub _TicketIDCheck {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    my $DBObject  = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Needed (qw(TicketID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # update state
    return if !$DBObject->Prepare(
        SQL => 'SELECT ticket_id FROM ps_checklist_ticket_info '
            . ' WHERE ticket_id = ?',
        Bind => [
            \$Param{TicketID},
        ],
    );

    my $TicketID;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $TicketID = $Data[0];
    }

    return $TicketID;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

