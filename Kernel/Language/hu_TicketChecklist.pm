# --
# Kernel/Language/hu_TicketChecklist.pm - the Hungarian translation for Checklists
# Copyright (C) 2014-2016 Perl-Services, http://www.perl-services.de
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_TicketChecklist;

use strict;
use warnings;

use utf8;

our $VERSION = 0.01;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/TicketChecklist.xml
    $Lang->{'Module to show checklists in tickets.'} = 'Egy modul ellenőrzőlisták megjelenítéséhez a jegyekben.';
    $Lang->{'Shows a link in the menu to print a ticket or an article in the ticket zoom view of the agent interface.'} =
        'Egy hivatkozást jelenít meg a menüben egy jegy vagy egy bejegyzés nyomtatásához az ügyintézői felület jegynagyítás nézetében.';
    $Lang->{'Checklist'} = 'Ellenőrzőlista';
    $Lang->{'Maintain checklist for the ticket'} = 'Ellenőrzőlista karbantartása a jegynél';
    $Lang->{'Enable/Disable debugging feature.'} = 'Hibakeresési funkció engedélyezése vagy letiltása.';
    $Lang->{'No'} = 'Nem';
    $Lang->{'Yes'} = 'Igen';
    $Lang->{'The default state for a new checklist item.'} = 'Egy új ellenőrzőlista-elem alapértelmezett állapota.';
    $Lang->{'Frontend module registration for ticket checklist module.'} =
        'Előtétprogram-modul regisztráció a jegy ellenőrzőlista modulhoz.';
    $Lang->{'Maintain ticket checklists.'} = 'Jegy ellenőrzőlisták karbantartása.';
    $Lang->{'Maintain ticket checklists'} = 'Jegy ellenőrzőlisták karbantartása';
    $Lang->{'Frontend module registration for the checklist state administration.'} =
        'Előtétprogram-modul regisztráció az ellenőrzőlista állapotának adminisztrációjához.';
    $Lang->{'Create and manage checklist states.'} = 'Ellenőrzőlista-állapotok létrehozása és kezelése.';
    $Lang->{'Checklist States'} = 'Ellenőrzőlista-állapotok';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateList.tt
    $Lang->{'Checklist Item State Management'} = 'Ellenőrzőlista elemállapotának kezelése';
    $Lang->{'Actions'} = 'Műveletek';
    $Lang->{'Add State'} = 'Állapot hozzáadása';
    $Lang->{'List'} = 'Lista';
    $Lang->{'ID'} = 'Azonosító';
    $Lang->{'Name'} = 'Név';
    $Lang->{'Valid'} = 'Érvényes';
    $Lang->{'No matches found.'} = 'Nincs találat.';
    $Lang->{'edit'} = 'szerkesztés';
    $Lang->{'delete'} = 'törlés';

    # Custom/Kernel/Output/HTML/Templates/Standard/AdminTicketChecklistStateForm.tt
    $Lang->{'Go to overview'} = 'Ugrás az áttekintőhöz';
    $Lang->{'Add/Change States'} = 'Állapotok hozzáadása vagy megváltoztatása';
    $Lang->{'done'} = 'kész';
    $Lang->{'A name is required.'} = 'Egy név kötelező.';
    $Lang->{'Color'} = 'Szín';
    $Lang->{'A color is required.'} = 'Egy szín kötelező.';
    $Lang->{'Save'} = 'Mentés';
    $Lang->{'or'} = 'vagy';
    $Lang->{'Cancel'} = 'Mégse';

    # Custom/Kernel/Output/HTML/Templates/Standard/AgentTicketChecklist.tt
    $Lang->{'Manage Checklist for ticket'} = 'Ellenőrzőlista kezelése a jegynél';
    $Lang->{'Cancel & close window'} = 'Mégse és ablak bezárása';
    $Lang->{'Toggle this widget'} = 'Felületi elem ki- vagy bekapcsolása';
    $Lang->{'Checklist Settings'} = 'Ellenőrzőlista beállítások';
    $Lang->{'Article #'} = 'Bejegyzés #';
    $Lang->{'Remove item'} = 'Elem eltávolítása';
    $Lang->{'Add item'} = 'Elem hozzáadása';
    $Lang->{'Submit'} = 'Elküldés';

    # Custom/Kernel/Output/HTML/Templates/Standard/TicketChecklistWidget.tt
    $Lang->{'Show or hide the content'} = 'A tartalom megjelenítése vagy elrejtése';
    $Lang->{'Ticket Checklist'} = 'Jegy ellenőrzőlista';

    # Custom/Kernel/Modules/AgentTicketChecklist.pm
    $Lang->{'No TicketID is given!'} = 'Nincs jegyazonosító megadva!';
    $Lang->{'Please contact the admin.'} = 'Vegye fel a kapcsolatot a rendszergazdával.';
    $Lang->{'You need %s permissions!'} = '%s jogosultságokra van szüksége!';

    # TicketChecklist.sopm (default TicketChecklist states)
    $Lang->{'open'} = 'nyitott';
    $Lang->{'done'} = 'kész';
    $Lang->{'rejected'} = 'elutasítva';
    $Lang->{'in progress'} = 'folyamatban';

    return 1;
}

1;
