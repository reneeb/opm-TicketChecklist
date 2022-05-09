# --
# Kernel/Language/de_TicketChecklist.pm - the German translation for Checklists
# Copyright (C) 2014 - 2022 Perl-Services, https://www.perl-services.de
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
    $Lang->{'Module to show checklists in tickets.'} = 'Modul zur Anzeige von Checklisten in Tickets.';
    $Lang->{'Shows a link in the ticket menu to manage the ticket checklist.'} = 'Zeigt einen Link im Ticketmenü zur Verwaltung der Ticket-Checkliste';
    $Lang->{'Checklist'} = 'Checkliste';
    $Lang->{'Maintain checklist for the ticket'} = 'Verwalten Sie eine Checkliste für das Ticket';
    $Lang->{'Enable/Disable debugging feature.'} = 'Ein-/Ausschalten des Debuggings';
    $Lang->{'No'} = 'Nein';
    $Lang->{'Yes'} = 'Ja';
    $Lang->{'The default state for a new checklist item.'} = 'Standardstatus für einen neuen Checklistenpunkt';
    $Lang->{'Frontend module registration for ticket checklist module.'} =
        'Frontendmodul-Registration für das Checklisten-Modul.';
    $Lang->{'Maintain ticket checklists.'} = 'Ticket-Checklisten verwalten.';
    $Lang->{'Maintain ticket checklists'} = 'Ticket-Checklisten verwalten';
    $Lang->{'Frontend module registration for the checklist state administration.'} = '';
    $Lang->{'Create and manage checklist states.'} = 'Erstellen und Verwalten von Checklist Status.';
    $Lang->{'Checklist States'} = 'Checklist Status';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateList.tt
    $Lang->{'Checklist Item State Management'} = 'Checklisten Status Verwaltung';
    $Lang->{'Actions'} = 'Aktionen';
    $Lang->{'Add State'} = 'Status hinzufügen';
    $Lang->{'List'} = 'Übersicht';
    $Lang->{'ID'} = 'ID';
    $Lang->{'Name'} = 'Name';
    $Lang->{'Valid'} = 'Gültig';
    $Lang->{'No matches found.'} = 'Keine Treffer gefunden.';
    $Lang->{'edit'} = 'bearbeiten';
    $Lang->{'delete'} = 'löschen';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateForm.tt
    $Lang->{'Go to overview'} = 'Zur Übersicht gehen';
    $Lang->{'Add/Change States'} = 'Status Hinzufügen / Ändern';
    $Lang->{'done'} = 'erledigt';
    $Lang->{'A name is required.'} = 'Ein Name ist erforderlich';
    $Lang->{'Color'} = 'Farbe';
    $Lang->{'A color is required.'} = 'Eine Farbe ist erforderlich';
    $Lang->{'Save'} = 'Speichern';
    $Lang->{'or'} = 'oder';
    $Lang->{'Cancel'} = 'Abbrechen';

    # Custom/Kernel/Output/HTML/Templates/Standard/AgentTicketChecklist.tt
    $Lang->{'Manage Checklist for ticket'} = 'Verwalten Sie eine Checkliste für das Ticket';
    $Lang->{'Cancel & close window'} = 'Abbrechen und Fenster schließen';
    $Lang->{'Toggle this widget'} = 'Dieses Widget umschalten';
    $Lang->{'Checklist Settings'} = 'Checkliste Einstellungen';
    $Lang->{'Article #'} = 'Artikel #';
    $Lang->{'Remove item'} = 'Aufgabe löschen';
    $Lang->{'Add item'} = 'Aufgabe hinzufügen';
    $Lang->{'Submit'} = 'Übermitteln';

    # Custom/Kernel/Output/HTML/Templates/Standard/TicketChecklistWidget.tt
    $Lang->{'Show or hide the content'} = 'Inhalt anzeigen oder ausblenden';
    $Lang->{'Ticket Checklist'} = 'Ticket Checkliste';

    # Custom/Kernel/Modules/AgentTicketChecklist.pm
    $Lang->{'No TicketID is given!'} = 'Keine TicketID übermittelt!';
    $Lang->{'Please contact the admin.'} = 'Bitte kontaktieren Sie ihren Administrator';
    $Lang->{'You need %s permissions!'} = 'Sie benötigen die %s-Berechtigung!';

    # TicketChecklist.sopm (default TicketChecklist states)
    $Lang->{'open'} = 'offen';
    $Lang->{'done'} = 'erledigt';
    $Lang->{'rejected'} = 'abgelehnt';
    $Lang->{'in progress'} = 'in Bearbeitung';

    $Lang->{"State cannot be delete. A checklist item uses this state."} = 'Der Status kann nicht gelöscht werden. Eine Aufgabe nutzt noch diesen Status.';

    $Lang->{"customerportal"} = "Kundenportal";

    return 1;
}

1;
