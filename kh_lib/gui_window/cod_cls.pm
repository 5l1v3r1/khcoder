package gui_window::cod_cls;
use base qw(gui_window);

use strict;


#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt('�����ǥ��󥰡����饹����ʬ��'));

	my $lf = $win->LabFrame(
		-label       => 'Options',
		-labelside   => 'acrosstop',
		-borderwidth => 2
	)->pack(
		-fill   => 'both',
		-expand => 1
	);

	# �롼�롦�ե�����
	my %pack0 = (
		-anchor => 'w',
		#-padx => 2,
		#-pady => 2,
		-fill => 'x',
		-expand => 0,
	);
	$self->{codf_obj} = gui_widget::codf->open(
		parent  => $lf,
		pack    => \%pack0,
		command => sub{$self->read_cfile;},
	);
	
	# �����ǥ���ñ��
	my $f1 = $lf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 4
	);
	$f1->Label(
		-text => $self->gui_jchar('�����ǥ���ñ�̡�'),
		-font => "TKFN",
	)->pack(-side => 'left');
	my %pack1 = (
		-anchor => 'w',
		-padx => 2,
		-pady => 2,
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f1,
		pack   => \%pack1,
	);

	# ����������
	$lf->Label(
		-text => $self->gui_jchar('����������'),
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 0);

	my $f2 = $lf->Frame()->pack(
		-fill   => 'both',
		-expand => 1,
		-padx   => 2,
		-pady   => 2
	);

	$f2->Label(
		-text => $self->gui_jchar('����','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);

	my $f2_1 = $f2->Frame(
		-borderwidth        => 2,
		-relief             => 'sunken',
	)->pack(
			-anchor => 'w',
			-side   => 'left',
			-pady   => 2,
			-padx   => 2,
			-fill   => 'both',
			-expand => 1
	);

	# ������������HList
	$self->{hlist} = $f2_1->Scrolled(
		'HList',
		-scrollbars         => 'osoe',
		#-relief             => 'sunken',
		-font               => 'TKFN',
		-selectmode         => 'none',
		-indicator => 0,
		-highlightthickness => 0,
		-columns            => 1,
		-borderwidth        => 0,
		-height             => 12,
	)->pack(
		-fill   => 'both',
		-expand => 1
	);

	my $f2_2 = $f2->Frame()->pack(
		-fill   => 'x',
		-expand => 0,
		-side   => 'left'
	);
	$f2_2->Button(
		-text => $self->gui_jchar('��������'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->select_all;});}
	)->pack(-pady => 3);
	$f2_2->Button(
		-text => $self->gui_jchar('���ꥢ'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->select_none;});}
	)->pack();

	$lf->Label(
		-text => $self->gui_jchar('�����������ɤ�3�İʾ����򤷤Ʋ�������','euc'),
		-font => "TKFN",
	)->pack(
		-anchor => 'w',
		-padx   => 4,
	);

	# �����ǥ���ñ��
	#my $f4 = $lf->Frame()->pack(
	#	-fill => 'x',
	#	-padx => 2,
	#	-pady => 2
	#);
	#$f4->Label(
	#	-text => $self->gui_jchar('���르�ꥺ�ࡧ'),
	#	-font => "TKFN",
	#)->pack(-side => 'left');
	#
	#my $widget = gui_widget::optmenu->open(
	#	parent  => $f4,
	#	pack    => {-side => 'left'},
	#	options =>
	#		[
	#			[$self->gui_jchar('��ʿ��ˡ','euc'), 'average' ],
	#			[$self->gui_jchar('�Ƕ���ˡ','euc'), 'single'  ],
	#			[$self->gui_jchar('�Ǳ���ˡ','euc'), 'complete'],
	#			#[$self->gui_jchar('McQuittyˡ','euc'), 'mcquitty'],
	#		],
	#	variable => \$self->{method_opt},
	#);
	#$widget->set_value('average');

	# OK������󥻥�
	my $f3 = $win->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);

	$f3->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$self->{ok_btn} = $f3->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-state => 'disable',
		-command => sub{ $mw->after(10,sub{$self->_calc;});}
	)->pack(-side => 'right');

	$self->read_cfile;

	return $self;
}

# �����ǥ��󥰥롼�롦�ե�������ɤ߹���
sub read_cfile{
	my $self = shift;
	
	$self->{hlist}->delete('all');
	
	unless (-e $self->cfile ){
		$self->{code_obj} = undef;
		return 0;
	}
	
	my $cod_obj = kh_cod::func->read_file($self->cfile);
	
	unless (eval(@{$cod_obj->codes})){
		$self->{code_obj} = undef;
		return 0;
	}

	my $left = $self->{hlist}->ItemStyle('window',-anchor => 'w');

	my $row = 0;
	foreach my $i (@{$cod_obj->codes}){
		
		$self->{checks}[$row]{check} = 1;
		$self->{checks}[$row]{name}  = $i;
		
		my $c = $self->{hlist}->Checkbutton(
			-text     => gui_window->gui_jchar($i->name,'euc'),
			-variable => \$self->{checks}[$row]{check},
			-command  => sub{ 
				$self->win_obj->after(10,sub{ $self->check_selected_num; });
			},
			-anchor => 'w',
		);
		
		$self->{checks}[$row]{widget} = $c;
		
		$self->{hlist}->add($row,-at => "$row");
		$self->{hlist}->itemCreate(
			$row,0,
			-itemtype  => 'window',
			-style     => $left,
			-widget    => $c,
		);
		++$row;
	}
	$self->{code_obj} = $cod_obj;
	
	$self->check_selected_num;
	
	return $self;
}

# �����ɤ�1�İʾ����򤵤�Ƥ��뤫�����å�
sub check_selected_num{
	my $self = shift;
	
	my $selected_num = 0;
	foreach my $i (@{$self->{checks}}){
		++$selected_num if $i->{check};
	}
	
	if ($selected_num >= 3){
		$self->{ok_btn}->configure(-state => 'normal');
	} else {
		$self->{ok_btn}->configure(-state => 'disable');
	}
	return $self;
}

# ���٤�����
sub select_all{
	my $self = shift;
	foreach my $i (@{$self->{checks}}){
		$i->{widget}->select;
	}
	$self->check_selected_num;
	return $self;
}

# ���ꥢ
sub select_none{
	my $self = shift;
	foreach my $i (@{$self->{checks}}){
		$i->{widget}->deselect;
	}
	$self->check_selected_num;
	return $self;
}

# �ץ�åȺ�����ɽ��
sub _calc{
	my $self = shift;

	my @selected = ();
	foreach my $i (@{$self->{checks}}){
		push @selected, $i->{name} if $i->{check};
	}

	# �ǡ�������
	my $r_command;
	unless ( $r_command = $self->{code_obj}->out2r_selected($self->tani,\@selected) ){
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => "�и�����0�Υ����ɤ����ѤǤ��ޤ���"
		);
		$self->close();
		return 0;
	}
	
	# MDS�¹ԤΤ����R���ޥ��
	$r_command .= "\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "row.names(d) <- c(";
	foreach my $i (@{$self->{checks}}){
		my $name = $i->{name}->name;
		substr($name, 0, 2) = ''
			if index($name,'��') == 0
		;
		$r_command .= '"'.$name.'",'
			if $i->{check}
		;
	}
	chop $r_command;
	$r_command .= ")\n";
	
	my $r_command_2 = 
		 $r_command
		.'plot(hclust(dist(d,method="binary"),method="'
		.'single'
		.'"),labels=rownames(d), main="", sub="", xlab="",ylab="��Υ",cex=0.8)'
	;

	my $r_command_3 = 
		 $r_command
		.'plot(hclust(dist(d,method="binary"),method="'
		.'complete'
		.'"),labels=rownames(d), main="", sub="", xlab="",ylab="��Υ",cex=0.8)'
	;

	$r_command .=
		'plot(hclust(dist(d,method="binary"),method="'
		.'average'
		.'"),labels=rownames(d), main="", sub="", xlab="",ylab="��Υ",cex=0.8)'
	;

	# �ץ�åȺ���
	use kh_r_plot;
	my $plot1 = kh_r_plot->new(
		name      => 'codes_CLS1',
		command_f => $r_command,
	) or return 0;

	my $plot2 = kh_r_plot->new(
		name      => 'codes_CLS2',
		command_f => $r_command_2,
	) or return 0;

	my $plot3 = kh_r_plot->new(
		name      => 'codes_CLS3',
		command_f => $r_command_3,
	) or return 0;

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_cod_cls_plot')){
		$::main_gui->get('w_cod_cls_plot')->close;
	}
	$self->close;
	gui_window::cod_cls_plot->open(
		plots   => [$plot1,$plot2,$plot3],
	);
	
	return 1;
}

#--------------#
#   ��������   #

sub cfile{
	my $self = shift;
	return $self->{codf_obj}->cfile;
}
sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub win_name{
	return 'w_cod_cls';
}
1;