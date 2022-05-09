# --
# Copyright (C) 2020 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PerlServices::TicketChecklist::Event::RemoveTicketInfoFlags;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::Log
    Kernel::System::PerlServices::TicketChecklistTicketInfo
);

=head1 NAME

Kernel::System::PerlServices::Event::RemoveTicketInfoFlags

=head1 SYNOPSIS

Event handler module to update a ticket dynamic field that tracks if there are open todos for the ticket

=head1 PUBLIC INTERFACE

=over 4

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

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketInfoObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistTicketInfo');

    # check needed stuff
    for my $Argument (qw(Data Event Config UserID)) {
        if ( !$Param{$Argument} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Argument!"
            );

            return;
        }
    }

    # do not modify the original event, because we need this unmodified in later event modules
    my $Event    = $Param{Event};
    my $TicketID = $Param{Data}->{TicketID};

    return if !$TicketID;

    $TicketInfoObject->DeleteInfoForTicket(
        TicketID => $TicketID,
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
