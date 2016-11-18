# --
# Kernel/Modules/AdminTicketChecklistStates.pm - manage ticket checklist states
# Copyright (C) 2014 Perl-Services.de, http://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminTicketChecklistStates;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::PerlServices::TicketChecklistStatus
    Kernel::System::Valid
);

our $VERSION = 0.02;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
    my $StatusObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistStatus');

    my @Params = qw(ID Name ValidID Color);
    my %GetParam;
    for my $Param (@Params) {
        $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
    }

    # ------------------------------------------------------------ #
    # get data 2 form
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Edit' || $Self->{Subaction} eq 'Add' ) {
        my %Subaction = (
            Edit => 'Update',
            Add  => 'Save',
        );

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_MaskForm(
            %GetParam,
            %Param,
            Subaction => $Subaction{ $Self->{Subaction} },
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # update action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Update' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # server side validation
        my %Errors;
        if (
            !$GetParam{ValidID} ||
            !$ValidObject->ValidLookup( ValidID => $GetParam{ValidID} )
            )
        {
            $Errors{ValidIDInvalid} = 'ServerError';
        }

        for my $Param (qw(Name Color)) {
            if ( !$GetParam{$Param} ) {
                $Errors{ $Param . 'Invalid' } = 'ServerError';
            }
        }

        if ( %Errors ) {
            $Self->{Subaction} = 'Edit';

            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $Output .= $Self->_MaskForm(
                %GetParam,
                %Param,
                %Errors,
                Subaction => 'Update',
            );
            $Output .= $LayoutObject->Footer();

            return $Output;
        }

        my $Update = $StatusObject->TicketChecklistStatusUpdate(
            %GetParam,
            UserID  => $Self->{UserID},
        );

        if ( !$Update ) {
            return $LayoutObject->ErrorScreen();
        }

        return $LayoutObject->Redirect( OP => "Action=AdminTicketChecklistStates" );
    }

    # ------------------------------------------------------------ #
    # insert state
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Save' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # server side validation
        my %Errors;
        if (
            !$GetParam{ValidID} ||
            !$ValidObject->ValidLookup( ValidID => $GetParam{ValidID} )
            )
        {
            $Errors{ValidIDInvalid} = 'ServerError';
        }

        for my $Param (qw(Name Color)) {
            if ( !$GetParam{$Param} ) {
                $Errors{ $Param . 'Invalid' } = 'ServerError';
            }
        }

        if ( %Errors ) {
            $Self->{Subaction} = 'Add';

            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();
            $Output .= $Self->_MaskForm(
                %GetParam,
                %Param,
                %Errors,
                Subaction => 'Save',
            );
            $Output .= $LayoutObject->Footer();
            return $Output;
        }

        my $Success = $StatusObject->TicketChecklistStatusAdd(
            %GetParam,
            UserID  => $Self->{UserID},
            OwnerID => $GetParam{OwnerSelected},
        );

        if ( !$Success ) {
            return $LayoutObject->ErrorScreen();
        }

        return $LayoutObject->Redirect( OP => "Action=AdminTicketChecklistStates" );
    }

    elsif ( $Self->{Subaction} eq 'Delete' ) {
        $StatusObject->TicketChecklistStatusDelete( %GetParam );

        return $LayoutObject->Redirect( OP => "Action=AdminTicketChecklistStates" );
    }

    # ------------------------------------------------------------ #
    # else ! print form
    # ------------------------------------------------------------ #
    else {
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Self->_MaskForm();
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _MaskForm {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
    my $StatusObject = $Kernel::OM->Get('Kernel::System::PerlServices::TicketChecklistStatus');

    if ( $Self->{Subaction} eq 'Edit' ) {
        my %State = $StatusObject->TicketChecklistStatusGet( ID => $Param{ID} );
        for my $Key ( keys %State ) {
            $Param{$Key} = $State{$Key} if !$Param{$Key};
        }
    }

    my $ValidID = $ValidObject->ValidLookup( Valid => 'valid' );

    $Param{ValidSelect} = $LayoutObject->BuildSelection(
        Data       => { $ValidObject->ValidList() },
        Name       => 'ValidID',
        Size       => 1,
        SelectedID => $Param{ValidID} || $ValidID,
        HTMLQuote  => 1,
        Class      => 'Modernize',
    );

    if ( $Self->{Subaction} ne 'Edit' && $Self->{Subaction} ne 'Add' ) {

        my %StateList = $StatusObject->TicketChecklistStatusList();

        if ( !%StateList ) {
            $LayoutObject->Block(
                Name => 'NoStateFound',
            );
        }

        for my $StateID ( sort { $a <=> $b } keys %StateList ) {
        #for my $StateID ( sort { $StateList{$a} cmp $StateList{$b} } keys %StateList ) {
            my %State = $StatusObject->TicketChecklistStatusGet(
                ID => $StateID,
            );

            $LayoutObject->Block(
                Name => 'StateRow',
                Data => \%State,
            );
        }
    }

    $Param{SubactionName} = 'Update';
    $Param{SubactionName} = 'Save' if $Self->{Subaction} && $Self->{Subaction} eq 'Add';

    my $TemplateFile = 'AdminTicketChecklistStateList';
    $TemplateFile = 'AdminTicketChecklistStateForm' if $Self->{Subaction};

    return $LayoutObject->Output(
        TemplateFile => $TemplateFile,
        Data         => \%Param
    );
}

1;
