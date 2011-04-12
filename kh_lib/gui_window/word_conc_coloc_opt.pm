package gui_window::word_conc_coloc_opt;
use base qw(gui_window);

use Tk;

#-------------#
#   GUI����   #
#-------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	#$win->focus;
	$win->grab;
	$win->title($self->gui_jt('��������������� �ե��륿����'));
	#$self->{win_obj} = $win;
	
	my $left = $win->Frame()->pack(-fill => 'both', -expand => 1);

	# �ʻ�ˤ��ñ��μ������
	$left->Label(
		-text => $self->gui_jchar('���ʻ�ˤ���μ������'),
		-font => "TKFN"
	)->pack(-anchor => 'w');
	my $l3 = $left->Frame()->pack(-fill => 'both',-expand => 1);
	$l3->Label(
		-text => $self->gui_jchar('����'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left',-fill => 'y',-expand => 1);
	%pack = (
			-anchor => 'w',
			-side   => 'left',
			-pady   => 5,
			-fill   => 'y',
			-expand => 1
	);
	$self->{hinshi_obj} = gui_widget::hinshi->open(
		parent    => $l3,
		pack      => \%pack,
		selection => $gui_window::word_conc_coloc::filter->{hinshi},
	);
	my $l4 = $l3->Frame()->pack(-fill => 'x', -expand => 'y',-side => 'left');
	$l4->Button(
		-text => $self->gui_jchar('���٤�'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_all;});}
	)->pack(-pady => 2);
	$l4->Button(
		-text => $self->gui_jchar('������'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_default;});}
	)->pack(-pady => 2);
	$l4->Button(
		-text => $self->gui_jchar('���ꥢ'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_none;});}
	)->pack();

	# ɽ������LIMIT
	my $left3 = $win->Frame()->pack(-fill => 'x', -expand => 0);
	$left3->Label(
		-text => $self->gui_jchar('��ɽ�������ο�'),
		-font => "TKFN"
	)->pack(-anchor => 'w',-pady => 2);
	
	$left3->Label(
		-text => $self->gui_jchar('��������̡�'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left', -pady => 5);
	
	$self->{ent_limit} = $left3->Entry(
		-font  => "TKFN",
		-width => 6,
	)->pack(-anchor => 'w',-pady => 5);
	$self->config_entry_focusin($self->{ent_limit});

	# OK & Cancel
	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->save;});}
	)->pack(-side => 'right');
	
	# �ͤ�����
	$self->{ent_limit}->insert(
		"end",
		"$gui_window::word_conc_coloc::filter->{limit}"
	);
	
	return $self;
}


sub save{
	my $self = shift;
	
	$gui_window::word_conc_coloc::filter->{limit}   = $self->{ent_limit}->get;
	
	my %selected;
	foreach my $i (@{$self->{hinshi_obj}->selected}){
		$selected{$i} = 1;
	}
	foreach my $i (keys %{$gui_window::word_conc_coloc::filter->{hinshi}}){
			$gui_window::word_conc_coloc::filter->{hinshi}{$i} = $selected{$i};
	}
	
	$::main_gui->get('w_word_conc_coloc')->view;
	$self->close;
}


sub win_name{
	return 'w_word_conc_coloc_opt';
}

1;