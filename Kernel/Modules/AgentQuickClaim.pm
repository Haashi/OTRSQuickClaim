# Copyright (C) 2017 Haashii 

package Kernel::Modules::AgentQuickClaim;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # check needed stuff
    if ( !$Self->{TicketID} ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check permissions
    my $Access = $TicketObject->TicketPermission(
        Type     => 'owner',
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID}
    );

    # error screen, don't show ticket
    if ( !$Access ) {
        return $LayoutObject->NoPermission(
            Message    => "You need $Self->{Config}->{Permission} permissions!",
            WithHeader => 'yes',
        );
    }


    my $Success = $TicketObject->TicketOwnerSet(
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
        NewUserID => $Self->{UserID},
    );
    if ($Success) {
        $TicketObject->TicketLockSet(
            TicketID => $Self->{TicketID},
            Lock     => 'lock',
            UserID   => $Self->{UserID},
        );
    }
    return $LayoutObject->Redirect( OP => "Action=AgentTicketZoom;TicketID=$Self->{TicketID}" );
}

1;
