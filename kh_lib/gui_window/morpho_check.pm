package gui_window::morpho_check;
use base qw(gui_window);
use strict;
use Tk;
use Jcode;
use mysql_morpho_check;
use gui_window::morpho_detail;

#----------------#
#   Window�`��   #

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $mw->Toplevel;
	$wmw->focus;
	$wmw->title(Jcode->new('�`�ԑf��͌��ʂ̊m�F')->sjis);

	my $fra4 = $wmw->LabFrame(
		-label => 'Search Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'x');

	# �G���g���ƌ����{�^���̃t���[��
	my $fra4e = $fra4->Frame()->pack(-expand => 'y', -fill => 'x');
	my $e1 = $fra4e->Entry(
		-font => "TKFN"
	)->pack(expand => 'y', fill => 'x', side => 'left');
	$wmw->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);
	$e1->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$e1]);
	$e1->bind("<Shift-Key-Return>",sub{$self->search;});

	my $sbutton = $fra4e->Button(
		-text => Jcode->new('����')->sjis,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->search;});} 
	)->pack(-side => 'right', padx => '2');

	# ���ʕ\������
	my $fra5 = $wmw->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2
	)->pack(-expand=>'yes',-fill=>'both');

	my $hlist_fra = $fra5->Frame()->pack(-expand => 'y', -fill => 'both');

	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 2,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-command          => sub {$mw->after(10, sub{$self->detail;});},
		-height           => 20,
		-width            => 20,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => 'ID');
	$lis->header('create',1,-text => Jcode->new('���i�����ς݁j')->sjis);

	$fra5->Button(
		-text => Jcode->new('�R�s�[')->sjis,
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'right');

	$self->{conc_button} = $fra5->Button(
		-text => Jcode->new('�ڍו\��')->sjis,
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {$self->detail;});} 
	)->pack(-side => 'left');
	
	$self->{label} = $fra5->Label(
		-text => '    Ready.'
	)->pack(-side => 'left');

	MainLoop;
	
	$self->{list_f} = $hlist_fra;
	$self->{list}  = $lis;
	$self->{win_obj} = $wmw;
	$self->{entry}   = $e1;
	# $self->refresh;
	return $self;
}

#----------#
#   ����   #

sub search{
	my $self = shift;
	my $query = Jcode->new($self->entry->get)->euc;
	unless ($query){
		return;
	}
	$self->label->configure(-foreground => 'red', -text => 'Searching...');
	$self->win_obj->update;
	
	my $result = mysql_morpho_check->search(
		query   => $query,
	);
	
	$self->list->delete('all');
	my $row = 0;
	foreach my $i (@{$result}){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate($row,0,-text  => "$i->[1]");
		$self->list->itemCreate(
			$row,
			1,
			-text  => Jcode->new("$i->[0]")->sjis,
		);
		++$row;
	}
	$self->label->configure(-foreground => 'black', text => "    Hits: $row");
	$self->list->yview(0);
	$self->{result} = $result;
}

#--------------#
#   �ڍו\��   #

sub detail{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless(@selected){
		return;
	}
	my $selected = $selected[0];
	my $selected = $self->list->itemCget($selected, 0, -text);
	my $view_win = gui_window::morpho_detail->open;
	$view_win->view(
		query  => $selected,
		parent => $self
	);
}

sub next{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return;
	}
	my $selected = $selected[0] + 1;
	my $max = @{$self->result} - 1;
	if ($selected > $max){
		$selected = $max;
	}
	my $num = $self->list->itemCget($selected, 0, -text);
	
	$self->list->selectionClear;
	$self->list->selectionSet($selected);
	$self->list->yview($selected);
	my $n = @{$self->result};
	if ($n - $selected > 7){
		$self->list->yview(scroll => -5, 'units');
	}
	
	return $num;
}
sub prev{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return;
	}
	my $selected = $selected[0] - 1;
	if ($selected < 0){
		$selected = 0;
	}
	my $num = $self->list->itemCget($selected, 0, -text);

	$self->list->selectionClear;
	$self->list->selectionSet($selected);
	$self->list->yview($selected);
	my $n = @{$self->result};
	if ($n - $selected > 7){
		$self->list->yview(scroll => -5, 'units');
	}
	
	return $num;
}
sub if_next{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return;
	}
	my $selected = $selected[0];
	my $max = @{$self->result} - 1;
	if ($selected < $max){
		return 1;
	} else {
		return 0;
	}
}
sub if_prev{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return 0;
	}
	my $selected = $selected[0];
	if ($selected > 0){
		return 1;
	} else {
		return 0;
	}
}




sub win_name{return 'w_morpho_check';}
sub list{
	my $self = shift;
	return $self->{list};
}
sub entry{
	my $self = shift;
	return $self->{entry};
}
sub label{
	my $self = shift;
	return $self->{label};
}
sub result{
	my $self = shift;
	return $self->{result};
}
1;