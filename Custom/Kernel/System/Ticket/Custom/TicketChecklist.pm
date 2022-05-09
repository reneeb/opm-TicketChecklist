# --
# Copyright (C) 2017 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Custom::TicketChecklist;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

# disable redefine warnings in this scope
{
    no warnings 'redefine';

    my $OrigCode = *Kernel::System::Ticket::TicketDelete{CODE};
    
    *Kernel::System::Ticket::TicketDelete = sub {
        my ( $Self, %Param ) = @_;

        my $ChecklistObject  = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklist');
        my $TicketInfoObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistTicketInfo');

        # check needed stuff
        if ( $Param{UserID} && $Param{TicketID} ) {
            $TicketInfoObject->DeleteInfoForTicket(
                TicketID => $Param{TicketID},
            );

            $ChecklistObject->TicketChecklistDelete(
                TicketID => $Param{TicketID},
            );
        }
    
        return $Self->$OrigCode( %Param );
    };

}

1;

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
