# --
# Kernel/Modules/AgentTicketChecklistCustomerVisibility.pm - set customer visibility for the checklist
# Copyright (C) 2020 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketChecklistCustomerVisibility;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::Output::HTML::Layout
    Kernel::System::Web::Request
    Kernel::System::PerlServices::TicketChecklistTicketInfo
    Kernel::System::JSON
);

sub new {
    my ( $Type, %Param ) = @_;

    # create object
    my $Self = bless {%Param}, $Type;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $InfoObject   = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistTicketInfo');

    my $DEBUG = $ConfigObject->Get('TicketChecklist::Debug');

    # get parameters from request
    my %GetParam;
    for my $ParamName (qw(TicketID CustomerVisibility)) {
        $GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName ) || 0;
    }

    $GetParam{UserID} = $Self->{UserID};

    my $Success = $InfoObject->SetInfo( %GetParam );

    my $Result = { Success => $Success || 0 };

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSONObject->Encode( Data => $Result ),
        Type        => 'inline',
        NoCache     => 0,
    );
}

1;
