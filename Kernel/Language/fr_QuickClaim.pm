package Kernel::Language::fr_QuickClaim;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Shows a link in the menu to quick claim a ticket in the ticket zoom view of the agent interface.'}
        = 'Affiche une option dans le menu agent pour s\'approprier rapidement le ticket.';

    $Self->{Translation}->{'Claim this ticket'}
        = 'S\'approprier le ticket';

    return 1;
}

1;
