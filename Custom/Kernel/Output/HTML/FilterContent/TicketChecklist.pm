# --
# Kernel/Output/HTML/FilterContent/TicketChecklist.pm
# Copyright (C) 2014-2016 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterContent::TicketChecklist;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::System::Ticket
    Kernel::System::Web::Request
    Kernel::System::PerlServices::TicketChecklist
    Kernel::System::PerlServices::TicketChecklistStatus
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ChecklistObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklist');
    my $StatusObject    = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistStatus');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');

    # get template name
    #my $Templatename = $Param{TemplateFile} || '';
    my $Templatename = $ParamObject->GetParam( Param => 'Action' );

    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    # define if rich text should be used
    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );

    return 1 if !$TicketID;

    my @ChecklistItems = $ChecklistObject->TicketChecklistTicketGet(
        TicketID => $TicketID,
    );

    return 1 if !@ChecklistItems;

    my %StatusList   = $StatusObject->TicketChecklistStatusList();
    my %StatusColors;

    for my $StatusID ( keys %StatusList ) {
        my %StatusInfo = $StatusObject->TicketChecklistStatusGet(
            ID => $StatusID,
        );

        $StatusColors{$StatusID} = $StatusInfo{Color};
    }

    for my $Item ( @ChecklistItems ) {
        $Item->{StatusSelect} = $LayoutObject->BuildSelection(
            Name        => 'ItemStatusWidget_' . $Item->{Position},
            Data        => \%StatusList,
            SelectedID  => $Item->{StatusID},
            Translation => 1,
        );

        $Item->{Color} = $StatusColors{ $Item->{StatusID} };

        $LayoutObject->Block(
            Name => 'Item',
            Data => $Item,
        );

        if ( !$Item->{ArticleID} ) {
            $LayoutObject->Block(
                Name => 'TitlePlain',
                Data => $Item,
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'TitleLink',
                Data => $Item,
            );
        }
    }

    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'TicketChecklistWidget',
        Data         => {
            TicketID => $TicketID,
        },
    );

    my $Position = $ConfigObject->Get( 'TicketChecklist::Position' ) || 'top';

    if ( $Position eq 'bottom' ) {
        ${ $Param{Data} } =~ s{(</div> \s+ <div \s+ class="ContentColumn)}{ $Snippet $1 }xms;
    }
    else {
        ${ $Param{Data} } =~ s{(<div \s+ class="SidebarColumn">)}{$1 $Snippet}xsm;
    }

    my $JS = $LayoutObject->Output(
        Template => '<script type="text/javascript" src="[% Config("Frontend::JavaScriptPath") | html %]PS.TicketChecklistWidget.js"></script>',
    );

    ${ $Param{Data} } =~ s{</body}{$JS</body};

    return ${ $Param{Data} };
}

1;
