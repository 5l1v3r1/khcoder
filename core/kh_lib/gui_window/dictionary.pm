package gui_window::dictionary;
use base qw(gui_window);
use Tk;
use Tk::Checkbutton;
use Tk::HList;
use Tk::ItemStyle;
use strict;

use kh_dictio;

#----------------#
#   Windowɽ��   #
#----------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	
	my $wmw= $mw->Toplevel;
	#$wmw->focus;
	$wmw->title(Jcode->new('ʬ�Ϥ˻��Ѥ����μ������')->sjis);
	
	my $base = $wmw->Frame()->pack(-expand => '1', -fill => 'both');

	my $f_hinshi = $base->LabFrame(
		-label =>'word class',
		-labelside => 'acrosstop'
	)->pack(-side => 'left', -expand => '1', -fill => 'both');

	my $f_mark = $base->LabFrame(
		-label =>'force pick up',
		-labelside => 'acrosstop'
	)->pack(-side => 'left', -expand => '1', -fill => 'both');

	my $f_stop = $base->LabFrame(
		-label =>'force ignore',
		-labelside => 'acrosstop'
	)->pack(-side => 'right', -expand => '1', -fill => 'both');


	$f_hinshi->Label(
		-text => Jcode->new('���ʻ�ˤ��������')->sjis,
		-font => "TKFN"
	)->pack(-anchor=>'w');
	my $hlist = $f_hinshi->Scrolled(
		'HList',
		-scrollbars         => 'osoe',
#		-relief             => 'sunken',
		-font               => 'TKFN',
		-selectmode         => 'none',
		-indicator => 0,
		-command            => sub{$wmw->after(10,sub{$self->unselect;});},
		-highlightthickness => 0,
		-columns            => 2,
		-borderwidth        => 0,
	)->pack(-expand => '1', -fill => 'both');



	$f_mark->Label(
		-text => Jcode->new('��������Ф����λ���')->sjis,
		-font => "TKFN"
	)->pack(-anchor=>'w');
	$f_mark->Label(
		-text => Jcode->new('����ʣ���ξ��ϲ��ԤǶ��ڤ��')->sjis,
		-font => "TKFN"
	)->pack(-anchor=>'w');
	my $t1 = $f_mark->Scrolled(
		'Text',
		-scrollbars => 'osoe',
		-background => 'white',
		-height     => 18,
		-width      => 14,
		-wrap       => 'none',
		-font       => "TKFN",
	)->pack(-expand => 1, -fill => 'both');

	$f_stop->Label(
		-text => Jcode->new('�����Ѥ��ʤ���λ���')->sjis,
		-font => "TKFN"
	)->pack(-anchor=>'w');
	$f_stop->Label(
		-text => Jcode->new('����ʣ���ξ��ϲ��ԤǶ��ڤ��')->sjis,
		-font => "TKFN"
	)->pack(-anchor=>'w');
	my $t2 = $f_stop->Scrolled(
		'Text',
		-scrollbars => 'osoe',
		-height     => 18,
		-width      => 14,
		-wrap       => 'none',
		-font       => "TKFN",
		-background => 'white'
	)->pack(-expand => 1, -fill => 'both');

	# ʸ����������Х����
	$t1->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$t1]);
	$t1->bind("<Button-1>",[\&gui_jchar::check_mouse,\$t1]);
	$t2->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$t2]);
	$t2->bind("<Button-1>",[\&gui_jchar::check_mouse,\$t2]);

	# �ɥ�å����ɥ�å�
	$t1->DropSite(
		-dropcommand => [\&Gui_DragDrop::read_TextFile_droped,$t1],
		-droptypes => ($^O eq 'MSWin32' ? 'Win32' : ['KDE', 'XDND', 'Sun'])
	);
	$t2->DropSite(
		-dropcommand => [\&Gui_DragDrop::read_TextFile_droped,$t2],
		-droptypes => ($^O eq 'MSWin32' ? 'Win32' : ['KDE', 'XDND', 'Sun'])
	);

	$wmw->Label(
		-text => Jcode->new("(*) �ֶ�����Ф����פ�ֻ��Ѥ��ʤ���פλ�����ѹ�������硢\n�����������ѹ��Ϻ�����������Ԥ��ޤ�ȿ�Ǥ���ޤ���")->sjis,
		-font => 'TKFN',
		-justify => 'left',
	)->pack(-anchor => 'w', -side => 'left');

	$wmw->Button(
		-text => Jcode->new('����󥻥�')->sjis,
		-font => 'TKFN',
		-width => 8,
		-command => sub{
			$wmw->after(10,sub{$self->close;})
		}
	)->pack(-anchor=>'e',-side => 'right',-padx => 2);

	$wmw->Button(
		-text => 'OK',
		-font => 'TKFN',
		-width => 8,
		-command => sub{
			$wmw->after(10,sub{$self->save;})
		}
	)->pack(-anchor=>'e',-side => 'right');



	$self->{t1} = $t1;
	$self->{t2} = $t2;
	$self->{hlist} = $hlist;
	$self->{win_obj} = $wmw;
	
	$wmw->after(10,sub{$self->_fill_in;});

	return $self;

}

#---------------------------------------#
#   ���ߤ��������Ƥ�Windown�˽񤭹���   #
#---------------------------------------#

sub _fill_in{
	my $self = shift;
	$self->{config} = kh_dictio->readin;
	
	# �ʻ�ꥹ��
	my $row = 0;
	my @selection;
	my $right = $self->hlist->ItemStyle('window',-anchor => 'w');
	if ($self->config->hinshi_list){
		foreach my $i (@{$self->config->hinshi_list}){
			$selection[$row] = $self->config->ifuse_this($i);
			my $c = $self->hlist->Checkbutton(
				-text     => '',
				-variable => \$selection[$row],
			);
			$self->hlist->add($row,-at => $row,);
			$self->hlist->itemCreate(
				$row,0,
				-itemtype  => 'window',
				-style => $right,
				-widget    => $c,
			);
			
			$self->hlist->itemCreate(
				$row,1,
				-itemtype => 'text',
				-text     => Jcode->new($i)->sjis
			);
			++$row;
		}
		$self->{checks} = \@selection;
	}

	# �������
	if ($self->config->words_mk){
		foreach my $i (@{$self->config->words_mk}){
#			print "$i\n";
			my $t = Jcode->new($i)->sjis;
			$self->t1->insert('end',"$t\n");
		}
	}
	# ���Ѥ��ʤ���
	if ($self->config->words_st){
		foreach my $i (@{$self->config->words_st}){
			my $t = Jcode->new($i)->sjis;
			$self->t2->insert('end',"$t\n");
		}
	}
}

sub unselect{
	my $self = shift;
	$self->hlist->selectionClear();
	print "fuck\n";
}

#----------------------#
#   �������¸��Ŭ��   #
#----------------------#
sub save{
	my $self = shift;

	# �������
	my @mark; my %check;
	foreach my $i (split /\n/, Jcode->new($self->t1->get("1.0","end"))->euc){
		if ($i and not $check{$i}) {
			push @mark, $i;
			$check{$i} = 1;
		}
	}

	# ���Ѥ��ʤ���
	my @stop; %check = ();
	foreach my $i (split /\n/, Jcode->new($self->t2->get("1.0","end"))->euc){
		if ($i and not $check{$i}) {
			push @stop, $i;
			$check{$i} = 1;
		}
	}

	$self->config->words_mk(\@mark);
	$self->config->words_st(\@stop);

	# �ʻ�����
	if ($self->config->hinshi_list){
		my $row = 0;
		foreach my $i (@{$self->config->hinshi_list}){
		#	print Jcode->new("$i, ".$self->checks->[$row]."\n")->sjis;
			$self->config->ifuse_this($i,$self->checks->[$row]);
			++$row;
		}
	}


	$self->config->save;
	$self->close;
	
	# Main Window��ɽ���򹹿�
	$::main_gui->inner->refresh;
	
	if ( $::main_gui->if_opened('w_doc_ass') ){
		$::main_gui->get('w_doc_ass')->close;
	}
	
}


#--------------#
#   ��������   #
#--------------#
sub config{
	my $self = shift;
	return  $self->{config};
}

sub win_name{
	return 'w_dictionary';
}
sub t1{
	my $self = shift;
	return $self->{t1};
}
sub t2{
	my $self = shift;
	return $self->{t2};
}
sub hlist{
	my $self = shift;
	return $self->{hlist};
}
sub checks{
	my $self = shift;
	return $self->{checks};
}

1;
