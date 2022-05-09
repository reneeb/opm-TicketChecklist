# --
# Kernel/Language/de_TicketChecklist.pm - the German translation for Checklists
# Copyright (C) 2014 - 2022 Perl-Services, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::nb_NO_TicketChecklist;

use strict;
use warnings;

use utf8;

our $VERSION = 0.01;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/TicketChecklist.xml
    $Lang->{'Module to show checklists in tickets.'} = 'Modul som viser sjekklister i saker.';
    $Lang->{'Shows a link in the ticket menu to manage the ticket checklist.'} = 'Vis en lenke i saksmenyen for å administrere sakens sjekkliste.';
    $Lang->{'Checklist'} = 'Sjekkliste';
    $Lang->{'Maintain checklist for the ticket'} = 'Forvalte en sjekkliste for saken';
    $Lang->{'Enable/Disable debugging feature.'} = 'Slå Debuggingsstøtte på/av.';
    $Lang->{'No'} = 'Nei';
    $Lang->{'Yes'} = 'Ja';
    $Lang->{'The default state for a new checklist item.'} = 'Standardstatus for en ny sjekklistepunkt.';
    $Lang->{'Frontend module registration for ticket checklist module.'} =
        'Frontendmodulregistrering for sjekklistemodulen.';
    $Lang->{'Maintain ticket checklists.'} = 'Forvalte sakens sjekkliste.';
    $Lang->{'Maintain ticket checklists'} = 'Forvalte sakens sjekkliste';
    $Lang->{'Frontend module registration for the checklist state administration.'} = 'Frontendmodulregistrering for å administrere sjekklistestatusverdier';
    $Lang->{'Create and manage checklist states.'} = 'Opprette og forvalte sjekklistestatusverdier.';
    $Lang->{'Checklist States'} = 'Sjekklistestatus';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateList.tt
    $Lang->{'Checklist Item State Management'} = 'Forvalte status av sjekklistepunkt';
    $Lang->{'Actions'} = 'Aksjoner';
    $Lang->{'Add State'} = 'Legg til statusverdi';
    $Lang->{'List'} = 'Vis liste';
    $Lang->{'ID'} = 'ID';
    $Lang->{'Name'} = 'Navn';
    $Lang->{'Valid'} = 'Gyldig';
    $Lang->{'No matches found.'} = 'Ingen treff funnet.';
    $Lang->{'edit'} = 'bearbeide';
    $Lang->{'delete'} = 'slette';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateForm.tt
    $Lang->{'Go to overview'} = 'Gå til oversikten';
    $Lang->{'Add/Change States'} = 'Legg til / endre status';
    $Lang->{'done'} = 'ferdig';
    $Lang->{'A name is required.'} = 'Du må angi et navn';
    $Lang->{'Color'} = 'Farge';
    $Lang->{'A color is required.'} = 'En Farge er påkrevd';
    $Lang->{'Save'} = 'Lagre';
    $Lang->{'or'} = 'eller';
    $Lang->{'Cancel'} = 'Avbryte';

    # Custom/Kernel/Output/HTML/Templates/Standard/AgentTicketChecklist.tt
    $Lang->{'Manage Checklist for ticket'} = 'Forvalte en sjekkliste for saken';
    $Lang->{'Cancel & close window'} = 'Avbryt og lukk vinduet';
    $Lang->{'Toggle this widget'} = 'Gi widget motsatt verdi';
    $Lang->{'Checklist Settings'} = 'Sjekkliste innstillinger';
    $Lang->{'Article #'} = 'Innlegg #';
    $Lang->{'Remove item'} = 'Fjern punktet';
    $Lang->{'Add item'} = 'Legg til et punkt';
    $Lang->{'Submit'} = 'Send';

    # Custom/Kernel/Output/HTML/Templates/Standard/TicketChecklistWidget.tt
    $Lang->{'Show or hide the content'} = 'Vis eller gjem innholdet';
    $Lang->{'Ticket Checklist'} = 'Sakens sjekkliste';

    # Custom/Kernel/Modules/AgentTicketChecklist.pm
    $Lang->{'No TicketID is given!'} = 'SaksID ikke oppgitt!';
    $Lang->{'Please contact the admin.'} = 'Vennligst ta kontakt med administratoren';
    $Lang->{'You need %s permissions!'} = 'Du må ha %s-priviligier!';

    # TicketChecklist.sopm (default TicketChecklist states)
    $Lang->{'open'} = 'åpen';
    $Lang->{'done'} = 'ferdig';
    $Lang->{'rejected'} = 'avvist';
    $Lang->{'in progress'} = 'under bearbeiding';

    return 1;
}

1;
