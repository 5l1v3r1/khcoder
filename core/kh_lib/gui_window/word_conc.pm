package gui_window::word_conc;
use base qw(gui_window);
use strict;
use Tk;
use Tk::HList;
use NKF;
use mysql_conc;
use Jcode;

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $mw->Toplevel;
	$wmw->focus;
	$wmw->title(Jcode->new('���󥳡����󥹡�KIWIC��')->sjis);

	my $fra4 = $wmw->LabFrame(
		-label => 'Search Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'x');

	# ����ȥ�ȸ����ܥ���Υե졼��
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

	my $blhelp = $wmw->Balloon();
	$blhelp->attach(
		$sbutton,
		-balloonmsg => '"Shift + ENTER" key',
		-font => "TKFN"
	);

	# ���ץ���󡦥ե졼��
	my $fra4h = $fra4->Frame->pack(-expand => 'y', -fill => 'x');

	my @methods;
	push @methods, Jcode->new('AND����')->sjis;
	push @methods, Jcode->new('OR����')->sjis;
	my $method;
	$fra4h->Optionmenu(
		-options=> \@methods,
		-font => "TKFN",
		-variable => \$gui_window::word_search::method,
	)->pack(-anchor=>'e', -side => 'left');

	$fra4h->Checkbutton(
		-text     => Jcode->new('���ܷ��򸡺�')->sjis,
		-variable => \$gui_window::word_search::kihon,
		-font     => "TKFN",
		-command  => sub { $mw->after(10,sub{$self->refresh}); }
	)->pack(-side => 'left');

	$self->{the_check} = $fra4h->Checkbutton(
		-text     => Jcode->new('���Ѹ�ɽ��')->sjis,
		-variable => \$gui_window::word_search::katuyo,
		-font     => "TKFN",
		-command  => sub { $mw->after(10,sub{$self->refresh}); }
	)->pack(-side => 'left');
	
	unless (defined($gui_window::word_search::katuyo)){
		$gui_window::word_search::kihon = 1;
		$gui_window::word_search::katuyo = 0;
	}



	# ���ɽ����ʬ
	my $fra5 = $wmw->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2
	)->pack(-expand=>'yes',-fill=>'both');

	my $hlist_fra = $fra5->Frame()->pack(-expand => 'y', -fill => 'both');

	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 0,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
	)->pack(-fill =>'both',-expand => 'yes');

	$fra5->Button(
		-text => Jcode->new('���ԡ�')->sjis,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'left',-anchor => 'w');

	my $status = $fra5->Label(
		-text => 'Ready.',
		-foreground => 'blue'
	)->pack(-side => 'right', -anchor => 'e');

	MainLoop;

	$self->{st_label} = $status;
	$self->{list}     = $lis;
	$self->{win_obj}  = $wmw;
	$self->{entry}    = $e1;
	return $self;
}


#----------#
#   ����   #
#----------#

sub search{
	my $self = shift;
	
	# �ѿ�����
	my $query = Jcode->new($self->entry->get)->euc;
	unless ($query){
		return;
	}
	$self->st_label->configure(
		-text => 'Searching...',
		-foreground => 'red',
	);
	$self->win_obj->update;

	# �����¹�
	my $result = mysql_conc->a_word(
		query  => $query,
	);


	# ���ɽ��
	$self->list->delete('all');
	unless ($result){
		$self->st_label->configure(
			-text => 'Ready.',
			-foreground => 'blue',
		);
		$self->win_obj->update;
		return 0;
	}
	
	my $right_style = $self->list->ItemStyle(
		'text',
		-font => "TKFN",
		-anchor => 'e',
		-background => 'white'
	);
	my $center_style = $self->list->ItemStyle(
		'text',
		-anchor => 'c',
		-font => "TKFN",
		-background => 'white',
		-foreground => 'red'
	);

	my $row = 0;
	foreach my $i (@{$result}){
		$self->list->add($row,-at => "$row");
		
		
		$self->list->itemCreate(
			$row,
			0,
			-text  => nkf('-s -E',$i->[0]),
			-style => $right_style
		);
		$self->list->itemCreate(
			$row,
			1,
			-text  => nkf('-s -E',$i->[1]),
			-style => $center_style
		);
		$self->list->itemCreate(
			$row,
			2,
			-text  => nkf('-s -E',$i->[2])
		);
		++$row;
	}

	$self->st_label->configure(
		-text => 'Ready.',
		-foreground => 'blue',
	);
	$self->win_obj->update;

}


#--------------#
#   ��������   #
#--------------#

sub list{
	my $self = shift;
	return $self->{list};
}
sub entry{
	my $self = shift;
	return $self->{entry};
}
sub st_label{
	my $self= shift;
	return $self->{st_label};
}
sub win_name{
	return 'w_word_conc';
}

1;