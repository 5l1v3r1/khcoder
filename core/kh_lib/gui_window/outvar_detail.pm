package gui_window::outvar_detail;
use base qw(gui_window);
use strict;
use Tk;

use mysql_outvar;

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	my %args = @_;
	
	my $mw = $::main_gui->mw;
	my $wmw= $self->{win_obj};
	#$wmw->focus;
	$wmw->title($self->gui_jchar("�ѿ��ܺ١� "."$args{name}"));

	my $fra4 = $wmw->LabFrame(
		-label => 'Variables',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'both', -expand => 'yes');

	my $lis = $fra4->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'none',
		-command          => sub {$self->_open_var;},
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => $self->gui_jchar('��'));
	$lis->header('create',1,-text => $self->gui_jchar('��٥�'));
	$lis->header('create',2,-text => $self->gui_jchar('�ٿ�'));

	$wmw->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$wmw->Button(
		-text => $self->gui_jchar('OK'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->_save;});}
	)->pack(-side => 'right');

	#MainLoop;

	# ����μ�����ɽ��
	$self->{var_obj} = mysql_outvar::a_var->new($args{name});
	my $v = $self->{var_obj}->detail_tab;
	my $n = 0;
	my $right = $lis->ItemStyle('text',-anchor => 'e',-background => 'white');
	foreach my $i (@{$v}){
		$lis->add($n,-at => "$n");
		$lis->itemCreate($n,0,-text => $self->gui_jchar($i->[0]),);
		$lis->itemCreate(
			$n,
			2,
			-text  => $self->gui_jchar($i->[2]),
			-style => $right
		);
		
		my $c = $lis->Entry(
			-font  => "TKFN",
			-width => 15
		);
		$lis->itemCreate(
			$n,1,
			-itemtype  => 'window',
			-widget    => $c,
		);
		$c->insert(0,$self->gui_jchar($i->[1]));
		$c->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$c]);
		
		$self->{entry}{$i->[0]} = $c;
		$self->{label}{$i->[0]} = $i->[1];
		++$n;
	}
	$wmw->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);

	$self->{list}    = $lis;
	#$self->{win_obj} = $wmw;
	#$wmw->grab;
	return $self;
}

#--------------------#
#   �ե��󥯥����   #
#--------------------#

sub _save{
	my $self = shift;
	
	# �ѹ����줿��٥����¸
	foreach my $i (keys %{$self->{label}}){
		if (
			$self->{label}{$i}
			eq
			Jcode->new( $self->gui_jg($self->{entry}{$i}->get), 'sjis' )->euc
		){
			next;
		}
		$self->{var_obj}->label_save(
			Jcode->new($i)->euc,
			Jcode->new( $self->gui_jg($self->{entry}{$i}->get), 'sjis' )->euc,
		);
	}
	$self->close;
}

#--------------#
#   ��������   #
#--------------#


sub win_name{
	return 'w_outvar_detail';
}


1;
