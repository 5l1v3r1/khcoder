package gui_window::contxt_out;
use base qw(gui_window);

use gui_widget::tani_and_o;
use gui_widget::hinshi;
use mysql_crossout;
use mysql_contxt;

#-------------#
#   GUI����   #
#-------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	$win->title(Jcode->new($self->label)->sjis);
	$self->{win_obj} = $win;

	# �Ƽ�ե졼��
	my $wf = $win->Frame()->pack(-fill => 'both', -expand => 1);
	my $lf = $wf->LabFrame(
		-label => 'Words',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1, -side => left);
	my $rf = $wf->LabFrame(
		-label => 'Words for Context',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1, -side => left);
	my $of = $win ->LabFrame(
		-label => 'Optins',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-anchor => 'w', -side => left);
	my $bf = $win ->Frame(
		-borderwidth => 2
	)->pack(-anchor => 'se', -side => right);

	#--------------------#
	#   ���ץ��ץ����   #
	
	$of->Label(
		-text       => Jcode->new('������ñ�̤ȽŤ��դ�������')->sjis,
		-font       => "TKFN",
	)->pack(-anchor => 'w');

	$of->Label(
		-text => Jcode->new('����')->sjis,
		-font => "TKFN"
	)->pack(side => 'left',-fill => 'y',-expand => 1);

	$self->{tani_obj} = gui_widget::tani_and_o->open(
		parent => $of,
		pack   => {
			-anchor => 'w',
			-pady   => 2,
			-side   => 'left'
		}
	);

	#--------------------------------#
	#   ʸ̮�׻��˻��Ѥ���������   #

	my $right = $rf->Frame()->pack(-fill => 'both', -expand => 1);
	$right->Label(
		-text       => Jcode->new('��ʸ̮�٥��ȥ�η׻��˻��Ѥ����μ������')->sjis,
		-font       => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w');
	
	# �Ǿ�������и���
	$right->Label(
		-text => Jcode->new('���Ǿ�/���� �и����ˤ��������')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 5);
	my $r2 = $right->Frame()->pack(-fill => 'x');
	$r2->Label(
		-text => Jcode->new('�� ���Ǿ��и�����')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	$self->{ent_min2} = $r2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$r2->Label(
		-text => Jcode->new('�� ����и�����')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	$self->{ent_max2} = $r2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_min2}->insert(0,'1');

	# �ʻ�ˤ��ñ��μ������
	$right->Label(
		-text => Jcode->new('���ʻ�ˤ��������')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 5);
	my $r3 = $right->Frame()->pack(-fill => 'both',-expand => 1);
	$r3->Label(
		-text => Jcode->new('����')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left',-fill => 'y',-expand => 1);
	%pack = (
			-anchor => 'w',
			-side   => 'left',
			-pady   => 1,
			-fill   => 'y',
			-expand => 1
	);
	$self->{hinshi_obj2} = gui_widget::hinshi->open(
		parent => $r3,
		pack   => \%pack
	);
	my $r4 = $r3->Frame()->pack(-fill => 'x', -expand => 'y',-side => 'left');
	$r4->Button(
		-text => Jcode->new('��������')->sjis,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj2}->select_all;});}
	)->pack(-pady => 3);
	$r4->Button(
		-text => Jcode->new('���ꥢ')->sjis,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj2}->select_none;});}
	)->pack();

	$right->Label(
		-text => Jcode->new('�����ߤ�����Ƿ׻��˻��Ѥ�����ο�')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w');
	my $cf2 = $right->Frame->pack(-fill => 'x', -expand => '1');
	$cf2->Label(
		-text => Jcode->new('�� ��')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');
	$cf2->Button(
		-text => Jcode->new('�����å�')->sjis,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->check2;});}
	)->pack(-side => 'left', -padx => 2);
	$self->{ent_check2} = $cf2->Entry(
		-font       => "TKFN",
		-background => 'gray',
		-state      => 'disable'
	)->pack(-side => 'left',-fill => 'x', -expand => '1');

	#------------------#
	#   ��и������   #

	my $left = $lf->Frame()->pack(-fill => 'both', -expand => 1);
	$left->Label(
		-text       => Jcode->new('����и�μ������')->sjis,
		-font       => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w');
	
	# �Ǿ�������и���
	$left->Label(
		-text => Jcode->new('���Ǿ�/���� �и����ˤ��������')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 5);
	my $l2 = $left->Frame()->pack(-fill => 'x');
	$l2->Label(
		-text => Jcode->new('�� ���Ǿ��и�����')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	$self->{ent_min} = $l2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$l2->Label(
		-text => Jcode->new('�� ����и�����')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	$self->{ent_max} = $l2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_min}->insert(0,'1');

	# �ʻ�ˤ��ñ��μ������
	$left->Label(
		-text => Jcode->new('���ʻ�ˤ��������')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 5);
	my $l3 = $left->Frame()->pack(-fill => 'both',-expand => 1);
	$l3->Label(
		-text => Jcode->new('����')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left',-fill => 'y',-expand => 1);
	%pack = (
			-anchor => 'w',
			-side   => 'left',
			-pady   => 1,
			-fill   => 'y',
			-expand => 1
	);
	$self->{hinshi_obj} = gui_widget::hinshi->open(
		parent => $l3,
		pack   => \%pack
	);
	my $l4 = $l3->Frame()->pack(-fill => 'x', -expand => 'y',-side => 'left');
	$l4->Button(
		-text => Jcode->new('��������')->sjis,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_all;});}
	)->pack(-pady => 3);
	$l4->Button(
		-text => Jcode->new('���ꥢ')->sjis,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_none;});}
	)->pack();

	$left->Label(
		-text => Jcode->new('�����ߤ�����ǽ��Ϥ�����ο�')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w');
	my $cf = $left->Frame->pack(-fill => 'x', -expand => '1');
	$cf->Label(
		-text => Jcode->new('�� ��')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');
	$cf->Button(
		-text => Jcode->new('�����å�')->sjis,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->check1;});}
	)->pack(-side => 'left', -padx => 2);
	$self->{ent_check} = $cf->Entry(
		-font       => "TKFN",
		-background => 'gray',
		-state      => 'disable'
	)->pack(-side => 'left',-fill => 'x', -expand => '1');

	#----------------#
	#   �¹ԥܥ���   #

	$bf->Button(
		-text => Jcode->new('����󥻥�')->sjis,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$bf->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{
			$self->check or return;
			my $file = $self->file_name or return;
			my $ans = $self->win_obj->messageBox(
				-message => Jcode->new
					(
					   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
					   "³�Ԥ��Ƥ�����Ǥ�����"
					)->sjis,
				-icon    => 'question',
				-type    => 'OKCancel',
				-title   => 'KH Coder'
			);
			unless ( $ans =~ /ok/i ){ return 0; }
			my $w = gui_wait->start;
			$self->go($file);
			$w->end;
			$self->close;
		});}
	)->pack(-side => 'right');

	return $self;
}

#------------------------#
#   ��и���Υ����å�   #

sub check1{
	my $self = shift;
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	my $check = mysql_crossout->new(
		# tani   => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
	)->wnum;
	
	$self->{ent_check}->configure(-state => 'normal');
	$self->{ent_check}->delete(0,'end');
	$self->{ent_check}->insert(0,$check);
	$self->{ent_check}->configure(-state => 'disable');
}
sub check2{
	my $self = shift;
	unless ( eval(@{$self->hinshi2}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	my $check = mysql_crossout->new(
		# tani   => $self->tani,
		hinshi => $self->hinshi2,
		max    => $self->max2,
		min    => $self->min2,
	)->wnum;
	
	$self->{ent_check2}->configure(-state => 'normal');
	$self->{ent_check2}->delete(0,'end');
	$self->{ent_check2}->insert(0,$check);
	$self->{ent_check2}->configure(-state => 'disable');
}

#--------------#
#   ���å�   #
#--------------#

sub go{
	print "go!";
	
	my $self = shift;
	my $file = shift;
	
	mysql_contxt->new(
		tani    => $self->{tani_obj}->value,
		hinshi2 => $self->hinshi2,
		max2    => $self->max2,
		min2    => $self->min2,
		hinshi  => $self->hinshi,
		max     => $self->max,
		min     => $self->min,
	)->culc->save($file);
	
}

#-----------------#
#   ��¸��λ���  #

sub file_name{
	my $self = shift;
	my @types = (
		[ "spss syntax file",[qw/.sps/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.sps',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('����и��ʸ̮�٥��ȥ��ɽ��̾�����դ�����¸')->sjis,
		-initialdir       => $::config_obj->cwd
	);
	unless ($path){
		return 0;
	}
	return $path;
}

#--------------------------#
#   ���ϥ����å��롼����   #

sub check{
	my $self = shift;
	unless ( eval(@{$self->hinshi2}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	
	my $list = $self->{tani_obj}->value;
	my $n = @{$list};
	unless ($n){
		gui_errormsg->open(
			type => 'msg',
			msg  => '����ñ�̤�1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	return 1;
}


#--------------#
#   ��������   #
#--------------#

sub min{
	my $self = shift;
	return $self->{ent_min}->get;
}
sub max{
	my $self = shift;
	return $self->{ent_max}->get;
}
sub hinshi{
	my $self = shift;
	return $self->{hinshi_obj}->selected;
}
sub min2{
	my $self = shift;
	return $self->{ent_min2}->get;
}
sub max2{
	my $self = shift;
	return $self->{ent_max2}->get;
}
sub hinshi2{
	my $self = shift;
	return $self->{hinshi_obj2}->selected;
}




sub label{
	return '����и��ʸ̮�٥��ȥ��ɽ�ν��ϡ� SPSS';
}

sub win_name{
	return 'w_cross_out';
}


1;
