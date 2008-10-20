package gui_widget::hinshi;
use base qw(gui_widget);
use strict;
use Tk;
use Jcode;


sub _new{
	my $self = shift;
	
	my $height = 12;
	if ( defined($self->{height}) ){
		$height = $self->{height};
	}
	
	my $win = $self->parent->Frame(
		-borderwidth        => 2,
		-relief             => 'sunken',
	);
	
	$self->{hlist} = $win->Scrolled(
		'HList',
		-scrollbars         => 'osoe',
		#-relief             => 'sunken',
		-font               => 'TKFN',
		-selectmode         => 'none',
		-indicator => 0,
		-highlightthickness => 0,
		-columns            => 1,
		-borderwidth        => 0,
		-height             => $height,
	)->pack(
		-fill   => 'both',
		-expand => 1
	);
	
	
	my $right = $self->hlist->ItemStyle('window',-anchor => 'w');
	my $row = 0;
	my @selection;
	
	my $sth = mysql_exec->select("
		SELECT  name,khhinshi_id
		FROM    hselection
		WHERE   ifuse = 1
		ORDER BY khhinshi_id
	",1)->hundle;
	
	while (my $i = $sth->fetch){
		if ( defined($self->{selection}) ){
			$selection[$row] = $self->{selection}{$i->[1]};
		} else {
			$selection[$row] = 1;
		}
		$self->{name}{$row} = $i->[1];
		my $c = $self->hlist->Checkbutton(
			-text     => gui_window->gui_jchar($i->[0],'euc'),
			-variable => \$selection[$row],
			-anchor => 'w',
		);
		push @{$self->{check_wigets}}, $c;
		$self->hlist->add($row,-at => $row,);
		$self->hlist->itemCreate(
			$row,0,
			-itemtype  => 'window',
			-style => $right,
			-widget    => $c,
		);
		#$self->hlist->itemCreate(
		#	$row,1,
		#	-itemtype => 'text',
		#	-text     => gui_window->gui_jchar($i->[0],'euc')
		#);
		++$row;
	}
	$self->{checks} = \@selection;
	
	$self->{win_obj} = $win;
	return $self;
}

sub select_all{
	my $self = shift;
	foreach my $i (@{$self->{check_wigets}}){
		$i->select;
	}
}
sub select_none{
	my $self = shift;
	foreach my $i (@{$self->{check_wigets}}){
		$i->deselect;
	}
}

sub selected{
	my $self = shift;
	my @r;
	my $row = 0;
	foreach my $i (@{$self->{checks}}){
		if ($i){
			push @r, $self->{name}{$row};
		}
		++$row;
	}
	return \@r;
}

sub selection_get{
	my $self = shift;
	my $r;
	my $row = 0;
	foreach my $i (@{$self->{checks}}){
		$r->{$self->{name}{$row}} = $i;
		++$row;
	}
	return $r;
}


#--------------#
#   �A�N�Z�T   #

sub hlist{
	my $self = shift;
	return $self->{hlist};
}

1;