package gui_window::word_corresp;
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
		-label => 'Words',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1, -side => 'left');

	my $left = $lf->Frame()->pack(-fill => 'both', -expand => 1);
	# my $right = $lf->Frame()->pack(-side => 'right', -fill => 'x');

	$left->Label(
		-text => $self->gui_jchar('�����֤���������'),
		-font => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w', -pady => 2);

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
	$self->config_entry_focusin($self->{ent_min});
	
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
	$self->config_entry_focusin($self->{ent_max});

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
	$self->config_entry_focusin($self->{ent_min_df});

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
	$self->config_entry_focusin($self->{ent_max_df});

	# ����ñ�̤�����
	my $l1 = $left->Frame()->pack(-fill => 'x', -pady => 2);
	$l1->Label(
		-text => $self->gui_jchar('�� ��ʸ��ȸ��ʤ�ñ�̡�'),
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
		-text => $self->gui_jchar('�����ߤ���������֤�����ο���'),
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

	my $lf2 = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0);

	$self->{ent_check} = $cf->Entry(
		-font        => "TKFN",
		-background  => 'gray',
		-foreground  => 'black',
		-state       => 'disable',
	)->pack(-side => 'left', -fill => 'x', -expand => 1);
	$self->disabled_entry_configure($self->{ent_check});

	# ���ϥǡ���������

	$lf2->Label(
		-text => $self->gui_jchar('���б�ʬ�Ϥ�����'),
		-font => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w', -pady => 2);

	$lf2->Label(
		-text => $self->gui_jchar('��ʬ�Ϥ˻��Ѥ��륯��ɽ�μ��ࡧ'),
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 2);

	my $fi = $lf2->Frame()->pack(
		-fill   => 'x',
		-expand => 0,
		-padx   => 2,
		-pady   => 2
	);

	$fi->Label(
		-text => $self->gui_jchar('����','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);

	my $fi_1 = $fi->Frame(
		-borderwidth        => 2,
		-relief             => 'sunken',
	)->pack(
		-anchor => 'w',
		-side   => 'left',
		-pady   => 2,
		-padx   => 2,
		-fill   => 'x',
		-expand => 0
	);

	$self->{radio} = 0;
	$fi_1->Radiobutton(
		-text             => $self->gui_jchar('��и� �� ʸ��'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 0,
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $fi_2 = $fi_1->Frame()->pack(-anchor => 'w');
	$fi_2->Label(
		-text => $self->gui_jchar('����','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{label_high} = $fi_2->Label(
		-text => $self->gui_jchar('����ñ�̡�','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{opt_frame_high} = $fi_2;
	
	my $fi_4 = $fi_1->Frame()->pack(-anchor => 'w');
	$fi_4->Label(
		-text => $self->gui_jchar('����','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{label_high2} = $fi_4->Checkbutton(
		-text     => $self->gui_jchar('���Ф��ޤ���ʸ���ֹ��Ʊ������'),
		-variable => \$self->{biplot},
	)->pack(
		-anchor => 'w',
		-side  => 'left',
	);

	$fi_1->Radiobutton(
		-text             => $self->gui_jchar('��и� �� �����ѿ�'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 1,
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $fi_3 = $fi_1->Frame()->pack(-anchor => 'w');
	$fi_3->Label(
		-text => $self->gui_jchar('����','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{label_var} = $fi_3->Label(
		-text => $self->gui_jchar('�ѿ���','euc'),
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{opt_frame_var} = $fi_3;
	$self->refresh;

	# ��ʬ
	my $fd = $lf2->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 2,
	);

	$fd->Label(
		-text => $self->gui_jchar('����ʬ����'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_n} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_n}->insert(0,'2');
	$self->{entry_d_n}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_d_n});

	$fd->Label(
		-text => $self->gui_jchar('  x������ʬ��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_x} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_x}->insert(0,'1');
	$self->{entry_d_x}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_d_x});

	$fd->Label(
		-text => $self->gui_jchar('  y������ʬ��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_y} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_y}->insert(0,'2');
	$self->{entry_d_y}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_d_y});

	# �ե���ȥ�����
	my $ff = $lf2->Frame()->pack(
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
	$self->config_entry_focusin($self->{entry_font_size});

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
	$self->{entry_plot_size}->insert(0,'640');
	$self->{entry_plot_size}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_plot_size});

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

# �饸���ܥ����Ϣ
sub refresh{
	my $self = shift;
	unless ($self->{tani_obj}){return 0;}

	#------------------------#
	#   �����ѿ�����Widget   #

	my @options = ();
	my @tanis   = ();

	unless ($self->{opt_body_var}){
		# ���ѤǤ����ѿ������뤫�ɤ��������å�
		my $h = mysql_outvar->get_list;
		my @options = ();
		foreach my $i (@{$h}){
			push @options, [$self->gui_jchar($i->[1]), $i->[2]];
		}
		
		if (@options){
			$self->{opt_body_var} = gui_widget::optmenu->open(
				parent  => $self->{opt_frame_var},
				pack    => {-side => 'left', -padx => 2},
				options => \@options,
				variable => \$self->{var_id},
			);
			$self->{opt_body_var_ok} = 1;
		} else {
			$self->{opt_body_var} = gui_widget::optmenu->open(
				parent  => $self->{opt_frame_var},
				pack    => {-side => 'left', -padx => 2},
				options => 
					[
						[$self->gui_jchar('�����Բ�'), undef],
					],
				variable => \$self->{var_id},
			);
			$self->{opt_body_var_ok} = 0;
		}
	}

	#------------------------------#
	#   ��̤�ʸ��ñ������Widget   #

	unless ($self->{opt_body_high}){

		my %tani_name = (
			"bun" => "ʸ",
			"dan" => "����",
			"h5"  => "H5",
			"h4"  => "H4",
			"h3"  => "H3",
			"h2"  => "H2",
			"h1"  => "H1",
		);

		@tanis = ();
		foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
			if (
				mysql_exec->select(
					"select status from status where name = \'$i\'",1
				)->hundle->fetch->[0]
			){
				push @tanis, [$self->gui_jchar($tani_name{$i}),$i];
			}
		}

		if (@tanis){
			$self->{opt_body_high} = gui_widget::optmenu->open(
				parent  => $self->{opt_frame_high},
				pack    => {-side => 'left', -padx => 2},
				options => \@tanis,
				variable => \$self->{high},
			);
			$self->{opt_body_high_ok} = 1;
		} else {
			$self->{opt_body_high} = gui_widget::optmenu->open(
				parent  => $self->{opt_frame_high},
				pack    => {-side => 'left', -padx => 2},
				options => 
					[
						[$self->gui_jchar('�����Բ�'), undef],
					],
				variable => \$self->{high},
			);
			$self->{opt_body_high_ok} = 0;
		}
	}

	#----------------------------------#
	#   Widget��ͭ����̵�����ڤ��ؤ�   #

	if ($self->{radio} == 0){
		if ($self->{opt_body_high_ok}){
			$self->{opt_body_high}->configure(-state => 'normal');
		} else {
			$self->{opt_body_high}->configure(-state => 'disable');
		}
		$self->{label_high}->configure(-foreground => 'black');
		$self->{label_high2}->configure(-state => 'normal');
		
		$self->{opt_body_var}->configure(-state => 'disable');
		$self->{label_var}->configure(-foreground => 'gray');
	}
	elsif ($self->{radio} == 1){
		$self->{opt_body_high}->configure(-state => 'disable');
		$self->{label_high}->configure(-foreground => 'gray');
		$self->{label_high2}->configure(-state => 'disable');

		if ($self->{opt_body_var_ok}){
			$self->{opt_body_var}->configure(-state => 'normal');
		} else {
			$self->{opt_body_var}->configure(-state => 'disable');
		}
		$self->{label_var}->configure(-foreground => 'black');
	}
	
	return 1;
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
	
	my $tani2 = '';
	if ($self->{radio} == 0){
		$tani2 = $self->gui_jg($self->{high});
	}
	elsif ($self->{radio} == 1){
		if ( length($self->{var_id}) ){
			$tani2 = mysql_outvar::a_var->new(undef,$self->{var_id})->{tani};
		}
	}

	unless ($tani2){
		gui_errormsg->open(
			type => 'msg',
			msg  => '����ñ�̤ޤ����ѿ������������Ǥ���',
		);
		return 0;
	}

	my $rownames = 0;
	$rownames = 1 if ($self->{radio} == 0 and $self->{biplot} == 1);

	my $check_num = mysql_crossout::r_com->new(
		tani     => $self->tani,
		tani2    => $tani2,
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
			msg  => '���ʤ��Ȥ�3�İʾ����и�����֤��Ʋ�������',
		);
		return 0;
	}

	if ($check_num > 200){
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
					 '���ߤ�����Ǥ�'.$check_num.'�줬���֤���ޤ���'
					."\n"
					.'���֤����ο���100��150���٤ˤ������뤳�Ȥ�侩���ޤ���'
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
		tani2  => $tani2,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
		rownames => $rownames,
	)->run;

	# �����ѿ�����Ϳ
	if ($self->{radio} == 1){
		unless ($self->{var_id}){
			gui_errormsg->open(
				type   => 'msg',
				window  => \$self->win_obj,
				msg    => "�����ѿ������������Ǥ���"
			);
			return 0;
		}
		my $var_obj = mysql_outvar::a_var->new(undef,$self->{var_id});
		
		my $sql = '';
		$sql .= "SELECT $var_obj->{column} FROM $var_obj->{table} ";
		$sql .= "ORDER BY id";
		
		$r_command .= "v <- c(";
		my $h = mysql_exec->select($sql,1)->hundle;
		my $n = 0;
		while (my $i = $h->fetch){
			if ( length( $var_obj->{labels}{$i->[0]} ) ){
				my $t = $var_obj->{labels}{$i->[0]};
				$t =~ s/"/ /g;
				$r_command .= "\"$t\",";
			} else {
				$r_command .= "\"$i->[0]\",";
			}
			++$n;
		}
		
		chop $r_command;
		$r_command .= ")\n";
		$r_command .= "d <- aggregate(d,list(name = v), sum)\n";
		$r_command .= 'row.names(d) <- d$name'."\n";
		$r_command .= 'd$name <- NULL'."\n";
		
		$r_command .= 'd <- subset(d,row.names(d) != "��»��" & row.names(d) != "." & row.names(d) != "missing")'."\n";
	}

	# ���ιԡ����������
	$r_command .= "d <- subset(d, rowSums(d) > 0)\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "d <- subset(d, rowSums(d) > 0)\n";
	$r_command .= "d <- t(d)\n";

	my $biplot = 1;
	$biplot = 0 if $self->{radio} == 0 and $self->{biplot} == 0;

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	&make_plot(
		base_win  => $self,
		d_n       => $self->gui_jg( $self->{entry_d_n}->get ),
		d_x       => $self->gui_jg( $self->{entry_d_x}->get ),
		d_y       => $self->gui_jg( $self->{entry_d_y}->get ),
		biplot    => $biplot,
		plot_size => $self->gui_jg( $self->{entry_plot_size}->get ),
		font_size => $fontsize,
		r_command => $r_command,
	);
}


sub make_plot{
	my %args = @_;

	my $d_n = $args{d_n};
	my $d_x = $args{d_x};
	my $d_y = $args{d_y};
	my $fontsize = $args{font_size};
	my $r_command = $args{r_command};


	$r_command .= "library(MASS)\n";
	$r_command .= "c <- corresp(d, nf=$d_n)\n";

	my $r_command_tmp = $r_command;
	$r_command_tmp = Jcode->new($r_command_tmp)->sjis
		if $::config_obj->os eq 'win32';
	$::config_obj->R->send($r_command_tmp);

	# ��ͿΨ�μ���
	$::config_obj->R->send(
		'print( paste("khcoder", min(nrow(d), ncol(d)), sep="" ) )'
	);
	my $count = $::config_obj->R->read;
	my $kiyo1;
	my $kiyo2;
	if ($count =~ /"khcoder(.+)"/){
		$count = $1;
	} else {
		$count = -1;
	}
	while ($count > 0){
		#print "$count\n";
		$::config_obj->R->send(
			 'print( paste("khcoder",round('
			."c(c\$cor[$d_x], c\$cor[$d_y])^2"
			.'/sum(corresp(d, nf='
			.$count
			.')$cor^2) * 100,2), sep=""))'
		);
		my $t = $::config_obj->R->read;
		if ($t =~ /"khcoder(.+)".*"khcoder(.+)"/){
			$kiyo1 = $1;
			$kiyo2 = $2;
			last;
		}
		--$count;
	}

	# �ץ�åȤΤ����R���ޥ��

	my ($r_command_2a, $r_command_2, $r_command_a);
	if ($args{biplot} == 0){      # Ʊ�����֤ʤ�
		# ��٥�ȥɥåȤ�ץ�å�
		$r_command_2a = 
			 "plot(cbind(c\$cscore[,$d_x], c\$cscore[,$d_y]),"
				."col=\"mediumaquamarine\","
				.'pch=20,xlab="��ʬ'.$d_x
				.' ('.$kiyo1.'%)",ylab="��ʬ'.$d_y.' ('.$kiyo2.'%)")'
				."\n"
			."library(maptools)\n"
			."pointLabel(x=c\$cscore[,$d_x], y=c\$cscore[,$d_y],"
				."labels=rownames(c\$cscore), cex=$fontsize, offset=0)\n";
		;
		$r_command_2 = $r_command.$r_command_2a;
		
		# �ɥåȤΤߥץ�å�
		$r_command_a .=
			 "plot(cbind(c\$cscore[,$d_x], c\$cscore[,$d_y]),"
				.'xlab="��ʬ'.$d_x
				.' ('.$kiyo1.'%)",ylab="��ʬ'.$d_y.' ('.$kiyo2.'%)")'
				."\n"
		;
	} else {                                      # Ʊ�����֤���
		# ��٥�ȥɥåȤ�ץ�å�
		$r_command_2a .= 
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,$d_x], c\$cscore[,$d_y], 1),"
				."cbind(c\$rscore[,$d_x], c\$rscore[,$d_y], 2)"
				.'), xlab="��ʬ'.$d_x.' ('.$kiyo1
				.'%)", ylab="��ʬ'.$d_y.' ('.$kiyo2
				.'%)",pch=c(20,0)[cb[,3]],'
				.'col=c("mediumaquamarine","mediumaquamarine")[cb[,3]] )'."\n"
			."library(maptools)\n"
			."pointLabel("
				."x=c(c\$cscore[,$d_x], c\$rscore[,$d_x]),"
				."y=c(c\$cscore[,$d_y], c\$rscore[,$d_y]),"
				."labels=c(rownames(c\$cscore),rownames(c\$rscore)),"
				."cex=$fontsize, col=c(\"black\",\"red\")[cb[,3]], offset=0)"
		;
		$r_command_2 = $r_command.$r_command_2a;
		
		# �ɥåȤΤߤ�ץ�å�
		$r_command_a .=
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,$d_x], c\$cscore[,$d_y], 1),"
				."cbind(c\$rscore[,$d_x], c\$rscore[,$d_y], 2)"
				.'), xlab="��ʬ'.$d_x.' ('.$kiyo1
				.'%)", ylab="��ʬ'.$d_y.' ('.$kiyo2
				.'%)",pch=c(1,15)[cb[,3]] )'."\n"
		;
	}

	$r_command .= $r_command_a;

	# �ץ�åȺ���
	use kh_r_plot;
	my $plot1 = kh_r_plot->new(
		name      => 'words_CORRESP1',
		command_a => $r_command_a,
		command_f => $r_command,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or return 0;

	my $plot2 = kh_r_plot->new(
		name      => 'words_CORRESP2',
		command_a => $r_command_2a,
		command_f => $r_command_2,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or return 0;

	#$w->end(no_dialog => 1);

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_word_corresp_plot')){
		$::main_gui->get('w_word_corresp_plot')->close;
	}
	$args{base_win}->close;
	gui_window::r_plot::word_corresp->open(
		plots       => [$plot2,$plot1],
		no_geometry => 1,
	);

}



#--------------#
#   ��������   #


sub label{
	return '��и졦�б�ʬ�ϡʥ��ץ�����';
}

sub win_name{
	return 'w_word_corresp';
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