package gui_window::word_cls;
use base qw(gui_window);

use strict;

use Tk;

use gui_widget::tani;
use gui_widget::hinshi;
use mysql_crossout;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt($self->label));

	my $lf = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);

	my $left = $lf->Frame()->pack(-fill => 'both', -expand => 1);

	# ����ñ�̤�����
	my $l1 = $left->Frame()->pack(-fill => 'x', -pady => 2);
	$l1->Label(
		-text => $self->gui_jchar('������ñ�̡�'),
		-font => "TKFN"
	)->pack(-side => 'left');
	my %pack = (
			-anchor => 'e',
			-pady   => 0,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $l1,
		pack   => \%pack,
		dont_remember => 1,
	);

	# �Ǿ�������и���
	$left->Label(
		-text => $self->gui_jchar('���Ǿ�/���� �и����ˤ���μ������'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 2);
	my $l2 = $left->Frame()->pack(-fill => 'x', -pady => 2);
	$l2->Label(
		-text => $self->gui_jchar('�� ���Ǿ��и�����'),
		-font => "TKFN"
	)->pack(-side => 'left');
	$self->{ent_min} = $l2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_min}->insert(0,'1');
	$self->{ent_min}->bind("<Key-Return>",sub{$self->check;});
	
	$l2->Label(
		-text => $self->gui_jchar('�� ����и�����'),
		-font => "TKFN"
	)->pack(-side => 'left');
	$self->{ent_max} = $l2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_max}->bind("<Key-Return>",sub{$self->check;});

	# �Ǿ�������ʸ���
	$left->Label(
		-text => $self->gui_jchar('���Ǿ�/���� ʸ����ˤ���μ������'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 2);

	my $l3 = $left->Frame()->pack(-fill => 'x', -pady => 2);
	$l3->Label(
		-text => $self->gui_jchar('�� ���Ǿ�ʸ�����'),
		-font => "TKFN"
	)->pack(-side => 'left');
	$self->{ent_min_df} = $l3->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_min_df}->insert(0,'1');
	$self->{ent_min_df}->bind("<Key-Return>",sub{$self->check;});

	$l3->Label(
		-text => $self->gui_jchar('�� ����ʸ�����'),
		-font => "TKFN"
	)->pack(-side => 'left');
	$self->{ent_max_df} = $l3->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_max_df}->bind("<Key-Return>",sub{$self->check;});

	# �ʻ�ˤ��ñ��μ������
	$left->Label(
		-text => $self->gui_jchar('���ʻ�ˤ���μ������'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 2);
	my $l5 = $left->Frame()->pack(-fill => 'both',-expand => 1, -pady => 2);
	$l5->Label(
		-text => $self->gui_jchar('����'),
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
		parent => $l5,
		pack   => \%pack
	);
	my $l4 = $l5->Frame()->pack(-fill => 'x', -expand => 'y',-side => 'left');
	$l4->Button(
		-text => $self->gui_jchar('��������'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_all;});}
	)->pack(-pady => 3);
	$l4->Button(
		-text => $self->gui_jchar('���ꥢ'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_none;});}
	)->pack();

	# �����å���ʬ
	$lf->Label(
		-text => $self->gui_jchar('�����ߤ������ʬ�व����ο���'),
		-font => "TKFN"
	)->pack(-anchor => 'w');

	my $cf = $lf->Frame()->pack(-fill => 'x', -pady => 2);

	$cf->Label(
		-text => $self->gui_jchar('�� ��'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');

	$cf->Button(
		-text => $self->gui_jchar('�����å�'),
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->check;});}
	)->pack(-side => 'left', -padx => 2);

	$self->{ent_check} = $cf->Entry(
		-font        => "TKFN",
		-background  => 'gray',
		-foreground  => 'black',
		-state       => 'disable',
	)->pack(-side => 'left', -fill => 'x', -expand => 1);
	$self->disabled_entry_configure($self->{ent_check});

	# ���饹������
	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);
	$f4->Label(
		-text => $self->gui_jchar('�����饹��������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_cluster_number} = $f4->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_cluster_number}->insert(0,'0');
	$self->{entry_cluster_number}->bind("<Key-Return>",sub{$self->calc;});

	# �ե���ȥ�����
	my $ff = $lf->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 4,
	);

	$ff->Label(
		-text => $self->gui_jchar('���ե���ȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_font_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_font_size}->insert(0,'80');
	$self->{entry_font_size}->bind("<Key-Return>",sub{$self->calc;});

	$ff->Label(
		-text => $self->gui_jchar('%'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$ff->Label(
		-text => $self->gui_jchar('  �ץ�åȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_plot_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_plot_size}->insert(0,'Auto');
	$self->{entry_plot_size}->bind("<Key-Return>",sub{$self->calc;});

	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->calc;});}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');


	return $self;
}

#--------------#
#   �����å�   #
sub check{
	my $self = shift;
	
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	
	my $tani2 = '';
	if ($self->{radio} == 0){
		$tani2 = $self->gui_jg($self->{high});
	}
	elsif ($self->{radio} == 1){
		if ( length($self->{var_id}) ){
			$tani2 = mysql_outvar::a_var->new(undef,$self->{var_id})->{tani};
		}
	}
	
	my $check = mysql_crossout::r_com->new(
		tani   => $self->tani,
		tani2  => $tani2,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
	)->wnum;
	
	$self->{ent_check}->configure(-state => 'normal');
	$self->{ent_check}->delete(0,'end');
	$self->{ent_check}->insert(0,$check);
	$self->{ent_check}->configure(-state => 'disable');
}

#----------#
#   �¹�   #

sub calc{
	my $self = shift;
	
	# ���ϤΥ����å�
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}

	my $check_num = mysql_crossout::r_com->new(
		tani     => $self->tani,
		tani2    => $self->tani,
		hinshi   => $self->hinshi,
		max      => $self->max,
		min      => $self->min,
		max_df   => $self->max_df,
		min_df   => $self->min_df,
	)->wnum;
	
	$check_num =~ s/,//g;
	#print "$check_num\n";

	if ($check_num < 3){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���ʤ��Ȥ�3�İʾ����и�����򤷤Ʋ�������',
		);
		return 0;
	}

	if ($check_num > 500){
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
					 '���ߤ�����Ǥ�'.$check_num.'�줬���Ѥ���ޤ���'
					."\n"
					.'���Ѥ����ο���200��300���٤ˤ������뤳�Ȥ�侩���ޤ���'
					."\n"
					.'³�Ԥ��Ƥ�����Ǥ�����'
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }
	}

	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�����Ǥ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	unless ($ans =~ /ok/i){ return 0; }

	#my $w = gui_wait->start;

	# �ǡ����μ��Ф�
	my $r_command = mysql_crossout::r_com->new(
		tani   => $self->tani,
		tani2  => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
		rownames => 0,
	)->run;

	# ���饹����ʬ�Ϥ�¹Ԥ��뤿��Υ��ޥ��
	$r_command .= "d <- t(d)\n";
	$r_command .= "# END: DATA\n";

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;
	my $cluster_number = $self->gui_jg( $self->{entry_cluster_number}->get );

	my $par = 
		"par(
			mai=c(0,0,0,0),
			mar=c(1,2,1,0),
			omi=c(0,0,0,0),
			oma=c(0,0,0,0) 
		)\n"
	;

	my $r_command_2a = 
		"$par"
		.'plot(hclust(dist(d,method="binary"),method="'
			.'single'
			.'"),labels=rownames(d), main="", sub="", xlab="",ylab="",'
			."cex=$fontsize, hang=-1)\n"
	;
	$r_command_2a .= 
		'rect.hclust(hclust(dist(d,method="binary"),method="'
			.'single'
			.'"), k='.$cluster_number.', border="#FF8B00FF")'
		if $cluster_number > 1;
	
	my $r_command_2 = $r_command.$r_command_2a;

	my $r_command_3a = 
		"$par"
		.'plot(hclust(dist(d,method="binary"),method="'
			.'complete'
			.'"),labels=rownames(d), main="", sub="", xlab="",ylab="",'
			."cex=$fontsize, hang=-1)\n"
	;
	$r_command_3a .= 
		'rect.hclust(hclust(dist(d,method="binary"),method="'
			.'complete'
			.'"), k='.$cluster_number.', border="#FF8B00FF")'
		if $cluster_number > 1;
	my $r_command_3 = $r_command.$r_command_3a;

	$r_command .=
		"$par"
		.'plot(hclust(dist(d,method="binary"),method="'
			.'average'
			.'"),labels=rownames(d), main="", sub="", xlab="",ylab="",'
			."cex=$fontsize, hang=-1)\n"
	;
	$r_command .= 
		'rect.hclust(hclust(dist(d,method="binary"),method="'
			.'average'
			.'"), k='.$cluster_number.', border="#FF8B00FF")'
		if $cluster_number > 1;

	my $plot_size = $self->gui_jg( $self->{entry_plot_size}->get );
	if ($plot_size =~ /auto/i){
		$plot_size = int( ($check_num * 25 + 33) / 0.9344 );
		$plot_size = 640 if $plot_size < 640;
	}

	# �ץ�åȺ���
	use kh_r_plot;
	my $plot1 = kh_r_plot->new(
		name      => 'words_CLS1',
		command_f => $r_command,
		width     => $plot_size,
		height    => 480,
	) or return 0;
	$plot1->rotate_cls;

	my $plot2 = kh_r_plot->new(
		name      => 'words_CLS2',
		command_a => $r_command_2a,
		command_f => $r_command_2,
		width     => $plot_size,
		height    => 480,
	) or return 0;
	$plot2->rotate_cls;

	my $plot3 = kh_r_plot->new(
		name      => 'words_CLS3',
		command_a => $r_command_3a,
		command_f => $r_command_3,
		width     => $plot_size,
		height    => 480,
	) or return 0;
	$plot3->rotate_cls;

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_word_cls_plot')){
		$::main_gui->get('w_word_cls_plot')->close;
	}
	$self->close;
	gui_window::word_cls_plot->open(
		plots       => [$plot1,$plot2,$plot3],
		no_geometry => 1,
	);

	return 1;
}

#--------------#
#   ��������   #


sub label{
	return '��и졦���饹����ʬ�ϡʥ��ץ�����';
}

sub win_name{
	return 'w_word_cls';
}

sub min{
	my $self = shift;
	return $self->gui_jg( $self->{ent_min}->get );
}
sub max{
	my $self = shift;
	return $self->gui_jg( $self->{ent_max}->get );
}
sub min_df{
	my $self = shift;
	return $self->gui_jg( $self->{ent_min_df}->get );
}
sub max_df{
	my $self = shift;
	return $self->gui_jg( $self->{ent_max_df}->get );
}
sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}
sub hinshi{
	my $self = shift;
	return $self->{hinshi_obj}->selected;
}



1;