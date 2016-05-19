# --
# Kernel/Language/de_TicketChecklist.pm - the German translation for Checklists
# Copyright (C) 2014-2016 Perl-Services, http://www.perl-services.de
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

    # Kernel/Config/Files/TicketChecklist.xml
    $Lang->{'Module to show checklists in tickets.'} = '';
    $Lang->{'Shows a link in the menu to print a ticket or an article in the ticket zoom view of the agent interface.'} = '';
    $Lang->{'Checklist'} = 'Checkliste';
    $Lang->{'Maintain checklist for the ticket'} = 'Verwalten Sie eine Checkliste für das Ticket';
    $Lang->{'Enable/Disable debugging feature.'} = '';
    $Lang->{'No'} = 'Nein';
    $Lang->{'Yes'} = 'Ja';
    $Lang->{'Frontend module registration for ticket checklist module.'} =
        'Frontendmodul-Registration für das Checklisten-Modul.';
    $Lang->{'Maintain ticket checklists.'} = '';
    $Lang->{'Maintain ticket checklists'} = '';
    $Lang->{'Frontend module registration for the checklist state administration.'} = '';
    $Lang->{'Create and manage checklist states.'} = 'Erstellen und Verwalten von Checklist Status.';
    $Lang->{'Checklist States'} = 'Checklist Status';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateList.tt
    $Lang->{'Checklist Item State Management'} = '';
    $Lang->{'Actions'} = '';
    $Lang->{'Add State'} = '';
    $Lang->{'List'} = '';
    $Lang->{'ID'} = '';
    $Lang->{'Name'} = '';
    $Lang->{'Valid'} = '';
    $Lang->{'No matches found.'} = '';
    $Lang->{'edit'} = 'bearbeiten';
    $Lang->{'delete'} = '';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateForm.tt
    $Lang->{'Go to overview'} = '';
    $Lang->{'Add/Change States'} = 'Status Hinzufügen / Ändern';
    $Lang->{'done'} = 'erledigt';
    $Lang->{'A name is required.'} = '';
    $Lang->{'Color'} = 'Farbe';
    $Lang->{'A color is required.'} = '';
    $Lang->{'Save'} = '';
    $Lang->{'or'} = '';
    $Lang->{'Cancel'} = '';

    # Custom/Kernel/Output/HTML/Templates/Standard/AgentTicketChecklist.tt
    $Lang->{'Manage Checklist for ticket'} = 'Verwalten Sie eine Checkliste für das Ticket';
    $Lang->{'Cancel & close window'} = '';
    $Lang->{'Toggle this widget'} = '';
    $Lang->{'Checklist Settings'} = 'Checkliste Einstellungen';
    $Lang->{'Article #'} = 'Artikel #';
    $Lang->{'Remove item'} = '';
    $Lang->{'Add item'} = '';
    $Lang->{'Submit'} = '';

    # Custom/Kernel/Output/HTML/Templates/Standard/TicketChecklistWidget.tt
    $Lang->{'Show or hide the content'} = 'Inhalt anzeigen oder ausblenden';
    $Lang->{'Ticket Checklist'} = 'Ticket Checkliste';

    # Custom/Kernel/Modules/AgentTicketChecklist.pm
    $Lang->{'No TicketID is given!'} = '';
    $Lang->{'Please contact the admin.'} = '';
    $Lang->{'You need %s permissions!'} = '';

    # TicketChecklist.sopm (default TicketChecklist states)
    $Lang->{'open'} = '';
    $Lang->{'done'} = '';
    $Lang->{'rejected'} = '';

    return 1;
}

1;
