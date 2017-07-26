# Copyright (C) 2017 Haashii 

package Kernel::Modules::AgentQuickClaim;

use strict;
use warnings;
use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::Language;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check needed objects
    for (qw(ParamObject DBObject LayoutObject LogObject ConfigObject QueueObject TimeObject TicketObject)) {
        if ( !$Self->{$_} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $_!" );
        }
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;
	
	my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    my $DBObject = Kernel::System::DB->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
        MainObject   => $MainObject,
    );
    my $LanguageObject = Kernel::Language->new(
        MainObject   => $MainObject,
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
    );
    # check needed stuff
    if ( !$Self->{TicketID} ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check permissions
    my $Access = $Self->{TicketObject}->TicketPermission(
        Type     => 'owner',
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID}
    );

    # error screen, don't show ticket
    if ( !$Access ) {
        return $Self->{LayoutObject}->NoPermission(
            Message    => "You need $Self->{Config}->{Permission} permissions!",
            WithHeader => 'yes',
        );
    }

    my $Success = $Self->{TicketObject}->TicketOwnerSet(
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
        NewUserID => $Self->{UserID},
    );
    if ($Success) {
        $Self->{TicketObject}->TicketLockSet(
            TicketID => $Self->{TicketID},
            Lock     => 'lock',
            UserID   => $Self->{UserID},
        );
	my $From = "$Self->{UserFirstname} $Self->{UserLastname}";	
	my $ArticleID = $Self->{TicketObject}->ArticleCreate(
	        TicketID         => $Self->{TicketID},
	        ArticleType      => 'note-internal',                        # email-external|email-internal|phone|fax|...
	        SenderType       => 'agent',                                # agent|system|customer
	        Subject          => 'QuickClaim : '.$From,		                    # required
	        From		 => $From,
		Body             => $From,	                            # required
	        Charset          => 'ISO-8859-15',
	        MimeType         => 'text/plain',
	        HistoryType      => 'OwnerUpdate',                          # EmailCustomer|Move|AddNote|PriorityUpdate|WebRequestCustomer|...
	        HistoryComment   => 'New owner is '.$From,
	       	UserID           => $Self->{UserID}
  	 );
	
    }
    
    return $Self->{LayoutObject}->Redirect( OP => "Action=AgentTicketZoom;TicketID=$Self->{TicketID}" );
}
1;
