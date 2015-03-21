# --
# Kernel/Language/de_TicketChecklist.pm - the german translation for Checklists
# Copyright (C) 2014 Perl-Services, http://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_TicketChecklist;

use strict;
use warnings;

use utf8;

our $VERSION = 0.01;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'waiting'} = 'warten';
    $Lang->{'rejected'}  = 'abgelehnt';
    $Lang->{'done'}  = 'erledigt';
    $Lang->{'Add/Change States'}  = 'Status Hinzufügen / Ändern';
    $Lang->{'Color'}  = 'Farbe';
    $Lang->{'Checklist States'}  = 'Checklist Status';
    $Lang->{'create and manage checklist statuses.'}  = 'Erstellen und Verwalten von Checklist Status.';
    $Lang->{'Checklist Settings'}  = 'Checklist Einstellungen';
    $Lang->{'Maintain checklist for the ticket'}  = 'Verwalten Sie eine Checkliste für das Ticket';
    $Lang->{'Checklist'}  = 'Checkliste';
    $Lang->{'Manage Checklist for ticket'}  = 'Verwalten Sie eine Checkliste für das Ticket';
    $Lang->{'Ticket Checklist'}  = 'Ticket Checkliste';
    $Lang->{'edit'}  = 'bearbeiten';


    return 1;
}

1;
