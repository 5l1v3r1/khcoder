package gui_window::word_corresp;
use base qw(gui_window);

use strict;
use Tk;

use kh_r_plot;
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
		-label => kh_msg->get('option_words'),
		-labelside => 'acrosstop',
		-borderwidth => 2,
		-foreground => 'blue',
	)->pack(-fill => 'both', -expand => 0, -side => 'left',-anchor => 'w');

	my $rf = $win->Frame()
		->pack(-fill => 'both', -expand => 1);

	my $lf2 = $rf->LabFrame(
		-label => kh_msg->get('option_ca'),
		-labelside => 'acrosstop',
		-borderwidth => 2,
		-foreground => 'blue',
	)->pack(-fill => 'both', -expand => 1);

	$self->{words_obj} = gui_widget::words->open(
		parent       => $lf,
		verb         => kh_msg->get('plot'), # ����
		type         => 'corresp',
	);

	# ���ϥǡ���������
	$lf2->Label(
		-text => kh_msg->get('matrix'), # ʬ�Ϥ˻��Ѥ���ǡ���ɽ�μ��ࡧ
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 2);

	my $fi = $lf2->Frame()->pack(
		-fill   => 'both',
		-expand => 1,
		-padx   => 2,
		-pady   => 2
	);

	$fi->Label(
		-text => '    ',
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
		-fill   => 'both',
		-expand => 1
	);

	$self->{radio} = 0;
	$fi_1->Radiobutton(
		-text             => kh_msg->get('w_d'), # ��и� �� ʸ��
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 0,
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $fi_2 = $fi_1->Frame()->pack(-anchor => 'w');
	$fi_2->Label(
		-text => '    ',
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{label_high} = $fi_2->Label(
		-text => kh_msg->get('unit'), # ����ñ�̡�','euc
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{opt_frame_high} = $fi_2;
	
	my $fi_4 = $fi_1->Frame()->pack(-anchor => 'w');
	$fi_4->Label(
		-text => '    ',
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{label_high2} = $fi_4->Checkbutton(
		-text     => kh_msg->get('biplot'), # ���Ф��ޤ���ʸ���ֹ��Ʊ������
		-variable => \$self->{biplot},
	)->pack(
		-anchor => 'w',
		-side  => 'left',
	);

	$fi_1->Radiobutton(
		-text             => kh_msg->get('w_v'), # ��и� �� �����ѿ�
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 1,
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $fi_3 = $fi_1->Frame()->pack(
		-anchor => 'w',
		-fill   => 'both',
		-expand => 1,
	);
	
	$fi_3->Label(
		-text => '    ',
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{opt_frame_var} = $fi_3;
	
	$self->refresh;

	# ���ۤθ����ʸ�Τ�ʬ��
	$self->{check_filter_w} = 1;                  # �ǥե���Ȥ�ON
	my $fsw = $lf2->Frame()->pack(
		-fill => 'x',
		-pady => 2,
	);

	$fsw->Checkbutton(
		-text     => kh_msg->get('flw'), # ���ۤ������ʸ��ʬ�Ϥ˻��ѡ�
		-variable => \$self->{check_filter_w},
		-command  => sub{ $self->refresh_flw;},
	)->pack(
		-anchor => 'w',
		-side  => 'left',
	);

	$self->{entry_flw_l1} = $fsw->Label(
		-text => kh_msg->get('top'), # ���
		-font => "TKFN",
	)->pack(-side => 'left', -padx => 0);

	$self->{entry_flw} = $fsw->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 0);
	$self->{entry_flw}->insert(0,'60');
	$self->{entry_flw}->bind("<Key-Return>", sub{$self->calc;});
	$self->{entry_flw}->bind("<KP_Enter>",   sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_flw});

	$self->{entry_flw_l2} = $fsw->Label(
		-text => kh_msg->get('words'), # ��
		-font => "TKFN",
	)->pack(-side => 'left', -padx => 0);
	$self->refresh_flw;

	# ��ħŪ�ʸ�Τߥ�٥�ɽ��
	my $fs = $lf2->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 2,
	);

	$fs->Checkbutton(
		-text     => kh_msg->get('flt'), # ��������Υ�줿��Τߥ�٥�ɽ����
		-variable => \$self->{check_filter},
		-command  => sub{ $self->refresh_flt;},
	)->pack(
		-anchor => 'w',
		-side  => 'left',
	);

	$self->{entry_flt_l1} = $fs->Label(
		-text => kh_msg->get('top'), # ���
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_flt} = $fs->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 0);
	$self->{entry_flt}->insert(0,'60');
	$self->{entry_flt}->bind("<Key-Return>",sub{$self->calc;});
	$self->{entry_flt}->bind("<KP_Enter>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_flt});

	$self->{entry_flt_l2} = $fs->Label(
		-text => kh_msg->get('words'), # ��
		-font => "TKFN",
	)->pack(-side => 'left');
	$self->refresh_flt;

	# �Х֥�ץ�å�
	$self->{bubble_obj} = gui_widget::bubble->open(
		parent       => $lf2,
		type         => 'corresp',
		command      => sub{ $self->calc; },
		pack    => {
			-anchor   => 'w',
		},
	);

	# ��ʬ
	$self->{xy_obj} = gui_widget::r_xy->open(
		parent    => $lf2,
		command   => sub{ $self->calc; },
		pack      => { -anchor => 'w', -pady => 2 },
	);

	# �ե���ȥ�����
	$self->{font_obj} = gui_widget::r_font->open(
		parent    => $lf2,
		command   => sub{ $self->calc; },
		pack      => { -anchor   => 'w' },
		font_size => $::config_obj->r_default_font_size,
		show_bold => 0,
		plot_size => 640,
	);

	$rf->Checkbutton(
			-text     => kh_msg->gget('r_dont_close'), # �¹Ի��ˤ��β��̤��Ĥ��ʤ�
			-variable => \$self->{check_rm_open},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$rf->Button(
		-text => kh_msg->gget('cancel'), # ����󥻥�
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->withd;}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$rf->Button(
		-text => kh_msg->gget('ok'),
		-width => 8,
		-font => "TKFN",
		-command => sub{$self->calc;}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se')->focus;

	$self->_settings_load;

	return $self;
}

# �������¸�ʡ�OK�פ򥯥�å����Ƽ¹Ԥ�����ˡ�
sub _settings_save{
	my $self = shift;
	my $settings;

	$settings->{radio}     = $self->{radio};
	$settings->{tani2}     = $self->gui_jg($self->{high});
	$settings->{biplot}    = $self->{biplot};
	$settings->{var_id}    = $self->{var_id};

	#$settings->{d_n}       = $self->gui_jg( $self->{entry_d_n}->get );
	$settings->{d_x}       = $self->{xy_obj}->x,
	$settings->{d_y}       = $self->{xy_obj}->y,
	$settings->{plot_size} = $self->{font_obj}->plot_size,
	$settings->{font_size} = $self->{font_obj}->font_size,

	$::project_obj->save_dmp(
		name => $self->win_name,
		var  => $settings,
	);

	# ��и�������������¸���Ƥ���
	# ���ɤ߹��ߤϼ�ư��������¸�ϼ�ư�ġ�
	$self->{words_obj}->settings_save;

	return $self;
}

# ������ɤ߹��ߡʲ��̤򳫤����ˡ�
sub _settings_load{
	my $self = shift;

	return 1; # ���ε�ǽ�ǤΤ����꤬���٤���¸�����褦�ˤ���ȡ�
	          # ¾�ε�ǽ�ȤΥХ�󥹤��������ʤΤǡ���¸���Ƥ���
	          # �����ʺ��ν�˴������ɤ߹��ޤʤ����Ȥˡġ�

	my $settings = $::project_obj->load_dmp(
		name => $self->win_name,
	) or return 0;

	# ����ȥ꡼
	foreach my $i ('d_n', 'd_x', 'd_y', 'plot_size', 'font_size'){
		if ( length($settings->{$i}) ){
			$self->{'entry_'.$i}->delete(0,'end');
			$self->{'entry_'.$i}->insert(0,$settings->{$i});
		}
	}

	# ����и��ʸ��� or ����и�������ѿ���
	$self->{radio} = $settings->{radio};
	$self->refresh;

	# ����и��ʸ��פξ��
	if ( $self->{radio} == 0 ){
		$self->{opt_body_high}->set_value( $settings->{tani2} );
		if ($settings->{biplot}){
			$self->{label_high2}->select;
		} else {
			$self->{label_high2}->deselect;
		}
	}

	# ����и�������ѿ��פξ��
	elsif ( $self->{radio} == 1 ) {
		#$self->{opt_body_var}->set_value( $settings->{var_id} );
	}
}

# ����ħ������ܡפΥ����å��ܥå���
sub refresh_flt{
	my $self = shift;
	if ( $self->{check_filter} ){
		$self->{entry_flt}   ->configure(-state => 'normal');
		$self->{entry_flt_l1}->configure(-state => 'normal');
		$self->{entry_flt_l2}->configure(-state => 'normal');
	} else {
		$self->{entry_flt}   ->configure(-state => 'disabled');
		$self->{entry_flt_l1}->configure(-state => 'disabled');
		$self->{entry_flt_l2}->configure(-state => 'disabled');
	}
	return $self;
}

sub refresh_flw{
	my $self = shift;
	if ( $self->{check_filter_w} ){
		$self->{entry_flw}   ->configure(-state => 'normal');
		$self->{entry_flw_l1}->configure(-state => 'normal');
		$self->{entry_flw_l2}->configure(-state => 'normal');
	} else {
		$self->{entry_flw}   ->configure(-state => 'disabled');
		$self->{entry_flw_l1}->configure(-state => 'disabled');
		$self->{entry_flw_l2}->configure(-state => 'disabled');
	}
	return $self;
}




# �饸���ܥ����Ϣ
sub refresh{
	my $self = shift;
	unless ($self->tani){return 0;}

	#------------------------#
	#   �����ѿ�����Widget   #

	my @options = ();
	my @tanis   = ();

	unless ($self->{opt_body_var}){
		# ���ѤǤ����ѿ�������å�
		my $h = mysql_outvar->get_list;
		my @options = ();
		foreach my $i (@{$h}){
			push @options, [$self->gui_jchar($i->[1]), $i->[2]];
		}
		
		# �ꥹ��ɽ��
		$self->{opt_body_var} = gui_widget::chklist->open(
			parent  => $self->{opt_frame_var},
			options => \@options,
			default => 0,
			pack    => {
				-side   => 'left',
				-padx   => 2,
				-fill   => 'both',
				-expand => 1
			},
		);
		$self->{opt_body_var_ok} = 1;
	}

	#------------------------------#
	#   ��̤�ʸ��ñ������Widget   #

	unless ($self->{opt_body_high}){

		my %tani_name = (
			"bun" => kh_msg->gget('sentence'),
			"dan" => kh_msg->gget('paragraph'),
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
						[kh_msg->get('na'), undef], # �����Բ�
					],
				variable => \$self->{high},
			);
			$self->{opt_body_high_ok} = 0;
		}
		
		#print "ok0\n";
		if ($self->{high} =~ /h[1-5]/){
			my $chk =
				mysql_exec->select("select max(id) from $self->{high} ")
					->hundle->fetch->[0];
			#print "ok1\n";
			if ($chk <= 20){
				$self->{biplot} = 1;
				$self->{label_high2}->update;
				#print "ok2\n";
			}
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
		
		$self->{opt_body_var}->disable;
		#$self->{label_var}->configure(-foreground => 'gray');
	}
	elsif ($self->{radio} == 1){
		$self->{opt_body_high}->configure(-state => 'disable');
		$self->{label_high}->configure(-foreground => 'gray');
		$self->{label_high2}->configure(-state => 'disable');

		$self->{opt_body_var}->enable;

		#if ($self->{opt_body_var_ok}){
		#	#$self->{opt_body_var}->configure(-state => 'normal');
		#} else {
		#	#$self->{opt_body_var}->configure(-state => 'disable');
		#}
		#$self->{label_var}->configure(-foreground => 'black');
	}
	
	return 1;
}

sub start_raise{
	my $self = shift;
	$self->{words_obj}->settings_load;
}

sub start{
	my $self = shift;

	# Window���Ĥ���ݤΥХ����
	$self->win_obj->bind(
		'<Control-Key-q>',
		sub{ $self->withd; }
	);
	$self->win_obj->bind(
		'<Key-Escape>',
		sub{ $self->withd; }
	);
	$self->win_obj->protocol('WM_DELETE_WINDOW', sub{ $self->withd; });
}

#----------#
#   �¹�   #

sub calc{
	my $self = shift;
	
	# ���ϤΥ����å�
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => kh_msg->get('select_pos'), # �ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���
		);
		return 0;
	}

	my $tani2 = '';
	my $vars;
	if ($self->{radio} == 0){
		$tani2 = $self->gui_jg($self->{high});
	}
	elsif ($self->{radio} == 1){
		$vars = $self->{opt_body_var}->selected;
		unless ( @{$vars} ){
			gui_errormsg->open(
				type => 'msg',
				msg  => kh_msg->get('select_var'), # �����ѿ���1�İʾ����򤷤Ƥ���������
			);
			return 0;
		}
		
		foreach my $i (@{$vars}){
			if ($tani2){
				unless (
					$tani2
					eq mysql_outvar::a_var->new(undef,$i)->{tani}
				){
					gui_errormsg->open(
						type => 'msg',
						msg  => kh_msg->get('check_var_unit'), # ���ߤνꡢ����ñ�̤��ۤʤ볰���ѿ���Ʊ���˻��Ѥ��뤳�ȤϤǤ��ޤ���
					);
					return 0;
				}
			} else {
				$tani2 = mysql_outvar::a_var->new(undef,$i)
					->{tani};
			}
		}
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
			msg  => kh_msg->get('select_3words'), # ���ʤ��Ȥ�3�İʾ����и�����֤��Ʋ�������
		);
		return 0;
	}

	if ($check_num > 200){
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
					kh_msg->get('too_many1') # ���ߤ�����Ǥ�
					.$check_num
					.kh_msg->get('too_many2') # �줬���֤���ޤ���
					."\n"
					.kh_msg->get('too_many3') # ���֤����ο���100��150���٤ˤ������뤳�Ȥ�侩���ޤ���
					."\n"
					.kh_msg->get('too_many4') # ³�Ԥ��Ƥ�����Ǥ�����
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }
	}

	$self->_settings_save;

	my $w = gui_wait->start;

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
	$r_command .= "v_count <- 0\n";
	$r_command .= "v_pch   <- NULL\n";

	# �����ѿ�����Ϳ
	if ($self->{radio} == 1){
		
		my $n_v = 0;
		foreach my $i (@{$vars}){
			my $var_obj = mysql_outvar::a_var->new(undef,$i);
			
			my $sql = '';
			$sql .= "SELECT $var_obj->{column} FROM $var_obj->{table} ";
			$sql .= "ORDER BY id";
			
			$r_command .= "v$n_v <- c(";
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
			++$n_v;
		}
		
		$r_command .= &r_command_aggr($n_v);
	}

	# �����ѿ���̵���ä����
	$r_command .= '
		if ( length(v_pch) == 0 ) {
			v_pch   <- 3
			v_count <- 1
		}
	';

	# ���ιԡ����������
	$r_command .=
		"doc_length_mtr <- subset(doc_length_mtr, rowSums(d) > 0)\n";
	$r_command .=
		"d              <- subset(d,              rowSums(d) > 0)\n";
	$r_command .= "n_total <- doc_length_mtr[,2]\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "d <- subset(d, rowSums(d) > 0)\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "# END: DATA\n";

	my $biplot = 1;
	$biplot = 0 if $self->{radio} == 0 and $self->{biplot} == 0;

	my $filter = 0;
	if ( $self->{check_filter} ){
		$filter = $self->gui_jg( $self->{entry_flt}->get );
	}

	my $filter_w = 0;
	if ( $self->{check_filter_w} ){
		$filter_w = $self->gui_jg( $self->{entry_flw}->get );
	}

	my $plot = &make_plot(
		#d_n          => $self->gui_jg( $self->{entry_d_n}->get ),
		d_x          => $self->{xy_obj}->x,
		d_y          => $self->{xy_obj}->y,
		flt          => $filter,
		flw          => $filter_w,
		biplot       => $biplot,
		font_size    => $self->{font_obj}->font_size,
		font_bold    => $self->{font_obj}->check_bold_text,
		plot_size    => $self->{font_obj}->plot_size,
		r_command    => $r_command,
		bubble       => $self->{bubble_obj}->check_bubble,
		std_radius   => $self->{bubble_obj}->chk_std_radius,
		resize_vars  => $self->{bubble_obj}->chk_resize_vars,
		bubble_size  => $self->{bubble_obj}->size,
		bubble_var   => $self->{bubble_obj}->var,
		use_alpha    => $self->{bubble_obj}->alpha,
		plotwin_name => 'word_corresp',
	);

	$w->end(no_dialog => 1);

	# �ץ�å�Window�򳫤�
	my $plotwin_id = 'w_word_corresp_plot';
	if ($::main_gui->if_opened($plotwin_id)){
		$::main_gui->get($plotwin_id)->close;
	}
	
	gui_window::r_plot::word_corresp->open(
		plots       => $plot,
		#no_geometry => 1,
	);

	unless ( $self->{check_rm_open} ){
		$self->withd;
	}

}


sub make_plot{
	my %args = @_;
	$args{flt} = 0 unless $args{flt};
	$args{flw} = 0 unless $args{flw};

	my $fontsize = $args{font_size};
	my $r_command = $args{r_command};
	$args{use_alpha} = 0 unless ( length($args{use_alpha}) );

	#$r_command = Encode::decode('euc-jp', $r_command);
	$r_command = $r_command;

	kh_r_plot->clear_env;

	$r_command .= "d_x <- $args{d_x}\n";
	$r_command .= "d_y <- $args{d_y}\n";
	$r_command .= "flt <- $args{flt}\n";
	$r_command .= "flw <- $args{flw}\n";
	$r_command .= "biplot <- $args{biplot}\n";
	$r_command .= "cex=$fontsize\n";
	$r_command .= "use_alpha <- $args{use_alpha}\n";
	$r_command .= "
		if ( exists(\"saving_emf\") || exists(\"saving_eps\") ){
			use_alpha <- 0 
		}
	";

	$r_command .= "name_dim <- '".Encode::encode('euc-jp', kh_msg->get('dim'))."'\n"; # ��ʬ
	$r_command .= "name_eig <- '".Encode::encode('euc-jp', kh_msg->get('eig'))."'\n"; # ��ͭ��
	$r_command .= "name_exp <- '".Encode::encode('euc-jp', kh_msg->get('exp'))."'\n"; # ��ͿΨ

	$r_command .= "library(MASS)\n";
	#$r_command .= "c <- corresp(d, nf=min( nrow(d), ncol(d) ) )\n";

	$r_command .= &r_command_filter;

	$r_command .= "k <- c\$cor^2\n";
	$r_command .=
		"txt <- cbind( 1:length(k), round(k,4), round(100*k / sum(k),2) )\n";
	$r_command .= "colnames(txt) <- c(name_dim,name_eig,name_exp)\n";
	$r_command .= "print( txt )\n";
	$r_command .= "k <- round(100*k / sum(k),2)\n";

	# �ץ�åȤΤ����R���ޥ��

	my ($r_command_3a, $r_command_3);
	my ($r_command_2a, $r_command_2, $r_command_a);
	my ($r_com_gray, $r_com_gray_a);
	
	if ( $args{bubble} == 0 ){
	
	if ($args{biplot} == 0){                      # Ʊ�����֤ʤ�
		# ��٥�ȥɥåȤ�ץ�å�
		$r_command_2a = 
			 "plot(cb <- cbind(c\$cscore[,d_x], c\$cscore[,d_y], ptype),"
				.'col=c("mediumaquamarine","mediumaquamarine","#ADD8E6")[cb[,3]],'
				.'pch=c(20,1)[cb[,3]],'
				.'xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),'
				.'ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),'
				#.'bty="l"'
				.")\n"
			."library(maptools)\n"
			."labcd <- pointLabel(x=c\$cscore[,d_x], y=c\$cscore[,d_y],"
				."labels=rownames(c\$cscore), cex=$fontsize, offset=0, doPlot=F)\n"
			.'

xorg <- c$cscore[,d_x]
yorg <- c$cscore[,d_y]
#cex  <- 1

library(wordcloud)
nc <- wordlayout(
	labcd$x,
	labcd$y,
	rownames(c$cscore),
	cex=cex * 1.25,
	xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
	ylim=c(  par( "usr" )[3], par( "usr" )[4] )
)

xlen <- par("usr")[2] - par("usr")[1]
ylen <- par("usr")[4] - par("usr")[3]

for (i in 1:length( rownames(c$cscore) ) ){
	x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
	y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
	dst <- sqrt( x^2 + y^2 )
	if ( dst > 0.05 ){
		
		segments(
			nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
			xorg[i], yorg[i],
			col="gray60",
			lwd=1
		)
		
	}
}

xorg <- labcd$x
yorg <- labcd$y
labcd$x <- nc[,1] + .5 * nc[,3]
labcd$y <- nc[,2] + .5 * nc[,4]

text(
	labcd$x,
	labcd$y,
	rownames(c$cscore),
	cex=cex,
	offset=0
)

			'
		;
		$r_command_2 = $r_command.$r_command_2a;
		
		# �ɥåȤΤߥץ�å�
		$r_command_a .=
			 "plot(cb <- cbind(c\$cscore[,d_x], c\$cscore[,d_y], ptype),"
				.'pch=c(1,3)[cb[,3]],'
				.'xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),'
				.'ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),'
				#.'bty="l"'
				.")\n"
		;
	} else {                                      # Ʊ�����֤���
		# ��٥�ȥɥåȤ�ץ�å�
		$r_command_2a .= 
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,d_x], c\$cscore[,d_y], ptype),"
				."cbind(c\$rscore[,d_x], c\$rscore[,d_y], v_pch)"
				.'),'
				.'pch=c(20,1,0,2,4:15)[cb[,3]],'
				.'col=c("#66CCCC","#ADD8E6",rep( "#DC143C", v_count ))[cb[,3]],'
				.'xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),'
				.'ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),'
				.'cex=c(1,1,rep( pch_cex, v_count ))[cb[,3]],'
				#.'bty="l"'
				." )\n"
			."library(maptools)\n"
			."labcd <- pointLabel("
				."x=c(c\$cscore[,d_x], c\$rscore[,d_x]),"
				."y=c(c\$cscore[,d_y], c\$rscore[,d_y]),"
				."labels=c(rownames(c\$cscore),rownames(c\$rscore)),"
				."cex=$fontsize,offset=0,doPlot=F)\n"
			.'

xorg <- c(c$cscore[,d_x], c$rscore[,d_x])
yorg <- c(c$cscore[,d_y], c$rscore[,d_y])
#cex  <- 1

library(wordcloud)
nc <- wordlayout(
	labcd$x,
	labcd$y,
	rownames(cb),
	cex=cex * 1.25,
	xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
	ylim=c(  par( "usr" )[3], par( "usr" )[4] )
)

xlen <- par("usr")[2] - par("usr")[1]
ylen <- par("usr")[4] - par("usr")[3]

segs <- NULL
for (i in 1:length(rownames(cb)) ){
	x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
	y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
	dst <- sqrt( x^2 + y^2 )
	if ( dst > 0.05 ){
		segs <- rbind(
			segs,
			c(
				nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
				xorg[i], yorg[i]
			) 
		)
	}
}

xorg <- labcd$x
yorg <- labcd$y
labcd$x <- nc[,1] + .5 * nc[,3]
labcd$y <- nc[,2] + .5 * nc[,4]

if ( is.null(segs) == F){
	for (i in 1:nrow(segs) ){
		segments(
			segs[i,1],segs[i,2],segs[i,3],segs[i,4],
			col="gray60",
			lwd=1
		)
	}
}

			'
			.'text('
				.'labcd$x, labcd$y, rownames(cb),'
				."cex=$fontsize,"
				.'offset=0,'
				.'col=c("black",NA,rep("#FF6347",v_count) )[cb[,3]]' #336666��green�� #FF6347��vermilion�� #FF8B00FF��orange��
				.')'."\n"
		;
		$r_command_2 = $r_command.$r_command_2a;
		
		# �ѿ��ΤߤΥץ�å�
		$r_command_3a .= 
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,d_x], c\$cscore[,d_y], ptype),"
				."cbind(c\$rscore[,d_x], c\$rscore[,d_y], v_pch)"
				.'),'
				.'pch=c(1,1,0,2,4:15)[cb[,3]],'
				.'col=c("#ADD8E6","#ADD8E6",rep( "red", v_count ))[cb[,3]],'
				.'xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),'
				.'ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),'
				.'cex=c(1,1,rep( pch_cex, v_count ))[cb[,3]],'
				#.'bty="l"'
				." )\n"
			."library(maptools)\n"
			."labcd <- pointLabel("
				."x=c\$rscore[,d_x],"
				."y=c\$rscore[,d_y],"
				."labels=rownames(c\$rscore),"
				."cex=$fontsize,offset=0,doPlot=F)\n"
				.'

xorg <- c$rscore[,d_x]
yorg <- c$rscore[,d_y]
#cex  <- 1

library(wordcloud)
nc <- wordlayout(
	labcd$x,
	labcd$y,
	rownames(c$rscore),
	cex=cex * 1.25,
	xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
	ylim=c(  par( "usr" )[3], par( "usr" )[4] )
)

xlen <- par("usr")[2] - par("usr")[1]
ylen <- par("usr")[4] - par("usr")[3]

for (i in 1:length( rownames(c$rscore) ) ){
	x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
	y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
	dst <- sqrt( x^2 + y^2 )
	if ( dst > 0.05 ){
		
		segments(
			nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
			xorg[i], yorg[i],
			col="gray60",
			lwd=1
		)
		
	}
}

xorg <- labcd$x
yorg <- labcd$y
labcd$x <- nc[,1] + .5 * nc[,3]
labcd$y <- nc[,2] + .5 * nc[,4]

				'
			.'text('
				.'labcd$x, labcd$y, rownames(c$rscore),'
				."cex=$fontsize,"
				.'offset=0,'
				.'col="black"' # #336666
				.')'."\n"
		;
		$r_command_3 = $r_command.$r_command_3a;
		
		# ���졼��������Υץ�å�
		$r_com_gray_a .= &r_command_slab_my;
		$r_com_gray_a .= 
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,d_x], c\$cscore[,d_y], ptype),"
				."cbind(c\$rscore[,d_x], c\$rscore[,d_y], v_pch)"
				.'),'
				.'pch=c(20,1,0,2,4:15)[cb[,3]],'
				.'col=c("gray65","gray65",rep( "gray30", v_count))[cb[,3]],'
				.'xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),'
				.'ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),'
				#.'bty="l"'
				.")\n"
		;
		$r_com_gray =                             # command_f�ˤΤ��ɲ�
			 $r_command
			.$r_com_gray_a
			."library(maptools)\n"
			."labcd <- pointLabel("
				."x=c(c\$cscore[,d_x], c\$rscore[,d_x]),"
				."y=c(c\$cscore[,d_y], c\$rscore[,d_y]),"
				."labels=c(rownames(c\$cscore),rownames(c\$rscore)),"
				."cex=$fontsize,offset=0,doPlot=F)\n"
			.'

xorg <- c(c$cscore[,d_x], c$rscore[,d_x])
yorg <- c(c$cscore[,d_y], c$rscore[,d_y])
#cex  <- 1

library(wordcloud)
nc <- wordlayout(
	labcd$x,
	labcd$y,
	c(rownames(c$cscore),rownames(c$rscore)),
	cex=cex * 1.25,
	xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
	ylim=c(  par( "usr" )[3], par( "usr" )[4] )
)

xlen <- par("usr")[2] - par("usr")[1]
ylen <- par("usr")[4] - par("usr")[3]

segs <- NULL
for (i in 1:length( c(rownames(c$cscore),rownames(c$rscore)) ) ){
	x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
	y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
	dst <- sqrt( x^2 + y^2 )
	if ( dst > 0.05 ){
		segs <- rbind(
			segs,
			c(
				nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
				xorg[i], yorg[i]
			) 
		)
		
	}
}

xorg <- labcd$x
yorg <- labcd$y
labcd$x <- nc[,1] + .5 * nc[,3]
labcd$y <- nc[,2] + .5 * nc[,4]

			'
		;
		my $temp_cmd =                            # _f��_a�˶���
			 "cb  <- cbind(cb, labcd\$x, labcd\$y)\n"
			."cb1 <-  subset(cb, cb[,3]==1)\n"
			."cb2 <-  subset(cb, cb[,3]>=3)\n"
			.'text('
				.'cb1[,4], cb1[,5], rownames(cb1),'
				."cex=$fontsize,"
				.'offset=0,'
				.'col="black",'
				.')'."\n"
			.'
if ( is.null(segs) == F){
	for (i in 1:nrow(segs) ){
		segments(
			segs[i,1],segs[i,2],segs[i,3],segs[i,4],
			col="gray60",
			lwd=1
		)
	}
}
			'
			."library(ade4)\n"
			.'s.label_my(cb2, xax=4, yax=5, label=rownames(cb2),'
				.'boxes=T,'
				."clabel=$fontsize,"
				.'addaxes=F,'
				.'include.origin=F,'
				.'grid=F,'
				.'cpoint=0,'
				.'cneig=0,'
				.'cgrid=0,'
				.'add.plot=T,'
				.')'."\n"
			.'points(cb2[,1], cb2[,2], pch=c(20,1,0,2,4:15)[cb2[,3]], col="gray30")'."\n"
		;
		$r_com_gray   .= $temp_cmd;
		$r_com_gray_a .= $temp_cmd;

		# �ɥåȤΤߤ�ץ�å�
		$r_command_a .=
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,d_x], c\$cscore[,d_y], ptype),"
				."cbind(c\$rscore[,d_x], c\$rscore[,d_y], v_pch)"
				.'),'
				.'pch=c(1,3,0,2,4:15)[cb[,3]],'
				.'xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),'
				.'ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),'
				#.'bty="l"'
				.")\n"
		;
	}
	$r_command .= $r_command_a;

	# �Х֥�ɽ����Ԥ����
	} else {
		# �����
		$r_command .= &r_command_slab_my;
		$r_command .= "font_size <- $fontsize\n";
		$r_command .= "std_radius <- $args{std_radius}\n";
		$r_command .= "resize_vars <- $args{resize_vars}\n";
		$r_command .= "bubble_size <- $args{bubble_size}\n";
		$r_command .= "bubble_var <- $args{bubble_var}\n";
		$r_command .= "labcd <- NULL\n\n";
		my $common = $r_command;
		
		# ���顼
		$r_command .= "plot_mode <- \"dots\"\n";
		$r_command .= &r_command_bubble;

		# �ɥåȤΤ�
		$r_command_2a .= "plot_mode <- \"color\"\n";
		$r_command_2a .= &r_command_bubble;
		$r_command_2  = $common.$r_command_2a;

		if ($args{biplot}){
			# �ѿ��Τ�
			$r_command_3a .= "plot_mode <- \"vars\"\n";
			$r_command_3a .= &r_command_bubble_v;
			$r_command_3  = $common.$r_command_3a;
			
			# ���졼��������
			$r_com_gray_a .= "plot_mode <- \"gray\"\n";
			$r_com_gray_a .= &r_command_bubble;
			$r_com_gray = $common.$r_com_gray_a;
		}
	}

	# �ץ�åȺ���
	my $flg_error = 0;
	my $plot1 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_1',
		command_f => $r_command,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my $plot2 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_2',
		command_a => $r_command_2a,
		command_f => $r_command_2,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my ($plotg, $plotv);
	my @plots = ();
	if ($r_com_gray_a){
		$plotg = kh_r_plot->new(
			name      => $args{plotwin_name}.'_g',
			command_a => $r_com_gray_a,
			command_f => $r_com_gray,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;
		
		$plotv = kh_r_plot->new(
			name      => $args{plotwin_name}.'_v',
			command_a => $r_command_3a,
			command_f => $r_command_3,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;
		@plots = ($plot2,$plotg,$plotv,$plot1);
	} else {
		@plots = ($plot2,$plot1);
	}

	my $txt = $plot1->r_msg;
	if ( length($txt) ){
		$txt = Jcode->new($txt)->sjis if $::config_obj->os eq 'win32';
		print "-------------------------[Begin]-------------------------[R]\n";
		print "$txt\n";
		print "---------------------------------------------------------[R]\n";
	}

	kh_r_plot->clear_env;

	return undef if $flg_error;

	return \@plots;
}

sub r_command_aggr{
	my $n_v = shift;
	my $t =
		"name_nav <- '"
		.Encode::encode('euc-jp', kh_msg->get('nav'))
		."'\n"; # ��»��
	$t .= << 'END_OF_the_R_COMMAND';

aggregate_with_var <- function(d, doc_length_mtr, v) {
	d              <- aggregate(d,list(name = v), sum)
	doc_length_mtr <- aggregate(doc_length_mtr,list(name = v), sum)

	row.names(d) <- d$name
	d$name <- NULL
	row.names(doc_length_mtr) <- doc_length_mtr$name
	doc_length_mtr$name <- NULL

	d              <- d[              order(rownames(d             )), ]
	doc_length_mtr <- doc_length_mtr[ order(rownames(doc_length_mtr)), ]

	doc_length_mtr <- subset(
		doc_length_mtr,
		row.names(d) != name_nav & row.names(d) != "." & row.names(d) != "missing"
	)
	d <- subset(
		d,
		row.names(d) != name_nav & row.names(d) != "." & row.names(d) != "missing"
	)

	# doc_length_mtr <- subset(doc_length_mtr, rowSums(d) > 0)
	# d              <- subset(d,              rowSums(d) > 0)

	return( list(d, doc_length_mtr) )
}

dd <- NULL
nn <- NULL

END_OF_the_R_COMMAND

	$t .= "for (i in list(";
	for (my $i = 0; $i < $n_v; ++$i){
		$t .= "v$i,";
	}
	chop $t;
	$t .= ")){\n";

	$t .= << 'END_OF_the_R_COMMAND2';

	cur <- aggregate_with_var(d, doc_length_mtr, i)
	dd <- rbind(dd, cur[[1]])
	nn <- rbind(nn, cur[[2]])
	v_count <- v_count + 1
	v_pch <- c( v_pch, rep(v_count + 2, nrow(cur[[1]]) ) )
}

d              <- dd
doc_length_mtr <- nn

END_OF_the_R_COMMAND2

	return $t;
}

sub r_command_filter{
	my $t = << 'END_OF_the_R_COMMAND';

# Filter words by chi-square value �����ܸ쥳����
if ( (flw > 0) && (flw < ncol(d)) ){
	sort  <- NULL
	for (i in 1:ncol(d) ){
		# print( paste(colnames(d)[i], chisq.test( cbind(d[,i], n_total - d[,i]) )$statistic) )
		sort <- c(
			sort, 
			chisq.test( cbind(d[,i], n_total - d[,i]) )$statistic
		)
	}
	d <- d[,order(sort,decreasing=T)]
	d <- d[,1:flw]
	d <- subset(d, rowSums(d) > 0)
}

c <- corresp(d, nf=min( nrow(d), ncol(d) ) )

# Dilplay Labels only for distinctive words
if ( (flt > 0) && (flt < nrow(c$cscore)) ){
	sort  <- NULL
	limit <- NULL
	names <- NULL
	ptype <- NULL
	
	# compute distance from (0,0)
	for (i in 1:nrow(c$cscore) ){
		sort <- c(sort, c$cscore[i,d_x] ^ 2 + c$cscore[i,d_y] ^ 2 )
	}
	
	# Put labels to top words
	limit <- sort[order(sort,decreasing=T)][flt]
	for (i in 1:nrow(c$cscore) ){
		if ( sort[i] >= limit ){
			names <- c(names, rownames(c$cscore)[i])
			ptype <- c(ptype, 1)
		} else {
			names <- c(names, NA)
			ptype <- c(ptype, 2)
		}
	}
	rownames(c$cscore) <- names;
} else {
	ptype <- 1
}

pch_cex <- 1
if ( v_count > 1 ){
	pch_cex <- 1.25
}

END_OF_the_R_COMMAND
return $t;
}

sub r_command_bubble{
	return '

col_bg_words <- NA
col_bg_vars  <- NA

if (plot_mode == "color"){
	col_txt_words <- "black"
	col_txt_vars  <- "#DC143C"
	col_dot_words <- "#00CED1"
	col_dot_vars  <- "#FF6347"
	if ( use_alpha == 1 ){
		col_bg_words <- "#48D1CC"
		col_bg_vars  <- "#FFA07A"
		
		rgb <- col2rgb(col_bg_words) / 255
		col_bg_words <- rgb( rgb[1], rgb[2], rgb[3], alpha=0.15 )
		rgb <- rgb * 0.75
		col_dot_words  <- rgb( rgb[1], rgb[2], rgb[3], alpha=0.6 )
		
		rgb <- col2rgb(col_bg_vars) / 255
		col_bg_vars <- rgb( rgb[1], rgb[2], rgb[3], alpha=0.15 )
	}
}

if (plot_mode == "gray"){
	col_txt_words <- "black"
	col_txt_vars  <- "black"
	col_dot_words <- "gray55"
	col_dot_vars  <- "gray30"
}

if (plot_mode == "vars"){
	col_txt_words <- NA
	col_txt_vars  <- "black"
	col_dot_words <- "#ADD8E6"
	col_dot_vars  <- "red"
}

if (plot_mode == "dots"){
	col_txt_words <- NA
	col_txt_vars  <- NA
	col_dot_words <- "black"
	col_dot_vars  <- "black"
}

# Bubble size
neg_to_zero <- function(nums){
  temp <- NULL
  for (i in 1:length(nums) ){
    if (nums[i] < 1){
      temp[i] <- 1
    } else {
      temp[i] <-  nums[i]
    }
  }
  return(temp)
}

b_size <- NULL
for (i in rownames(c$cscore)){
	if ( is.na(i) || is.null(i) || is.nan(i) ){
		b_size <- c( b_size, 1 )
	} else {
		b_size <- c( b_size, sum( d[,i] ) )
	}
}

b_size <- sqrt( b_size / pi ) # adjust bubble size: frequency ratio = square measure ratio

if (std_radius){ # standardize (enphasize) bubble size
	if ( sd(b_size) == 0 ){
		b_size <- rep(10, length(b_size))
	} else {
		b_size <- b_size / sd(b_size)
		b_size <- b_size - mean(b_size)
		b_size <- b_size * 5 * bubble_var / 100 + 10
		b_size <- neg_to_zero(b_size)
	}
}

# set plot area
plot(
	rbind(
		cbind(c$cscore[,d_x], c$cscore[,d_y], ptype),
		cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch)
	),
	pch=NA,
	col="black",
	xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),
	ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),
	#bty="l"
)

# draw bubbles of words
symbols(
	c$cscore[,d_x],
	c$cscore[,d_y],
	circles=b_size,
	inches=0.5 * bubble_size / 100,
	fg=c(col_dot_words,"#ADD8E6")[ptype],
	bg=c(col_bg_words,"#ADD8E6")[ptype],
	add=T,
)

# draw bubbles of variables
if (biplot){
	# bubble size
	if (resize_vars){
		pch_cex <- sqrt(n_total);
		pch_cex <- pch_cex * ( 10 / max(pch_cex) )
		if (std_radius){ # standardize (enphasize) bubble size
			if ( sd(pch_cex) == 0 ){
				pch_cex <- rep(10,length(pch_cex))
			} else {
				pch_cex <- pch_cex / sd(pch_cex)
				pch_cex <- pch_cex - mean(pch_cex)
				pch_cex <- pch_cex * 5 + 10
				pch_cex <- neg_to_zero(pch_cex)
				pch_cex <- pch_cex * ( 10 / max(pch_cex) )
			}
		}
		pch_cex <- pch_cex * bubble_size / 100
	}
	# plot points of variables
	points(
		cbb <- cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch),
		pch=c(20,1,22,23:25,21,4-14)[cbb[,3]],
		col=c("#66CCCC","#ADD8E6",rep( col_dot_vars, v_count ))[cbb[,3]],
		bg=col_bg_vars,
		cex=pch_cex,
	)
}

# compute label positions
if (biplot){
	cb <- rbind(
		cbind(c$cscore[,d_x], c$cscore[,d_y], ptype),
		cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch)
	)
} else {
	cb <- cbind(c$cscore[,d_x], c$cscore[,d_y], ptype)
}

if ( is.null(labcd) ){
	library(maptools)
	labcd <- pointLabel(
		x=cb[,1],
		y=cb[,2],
		labels=rownames(cb),
		cex=font_size,
		offset=0,
		doPlot=F
	)

	xorg <- cb[,1]
	yorg <- cb[,2]
	#cex  <- 1

	library(wordcloud)
	nc <- wordlayout(
		labcd$x,
		labcd$y,
		rownames(cb),
		cex=cex * 1.25,
		xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
		ylim=c(  par( "usr" )[3], par( "usr" )[4] )
	)

	xlen <- par("usr")[2] - par("usr")[1]
	ylen <- par("usr")[4] - par("usr")[3]

	segs <- NULL
	for (i in 1:length( rownames(cb) ) ){
		x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
		y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
		dst <- sqrt( x^2 + y^2 )
		if ( dst > 0.05 ){
			segs <- rbind(
				segs,
				c(
					nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
					xorg[i], yorg[i]
				) 
			)
			#segments(
			#	nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
			#	xorg[i], yorg[i],
			#	col="gray60",
			#	lwd=1
			#)
			
		}
	}

	xorg <- labcd$x
	yorg <- labcd$y
	labcd$x <- nc[,1] + .5 * nc[,3]
	labcd$y <- nc[,2] + .5 * nc[,4]


}

# draw labels
if (plot_mode == "gray"){
	cb  <- cbind(cb, labcd$x, labcd$y)
	cb1 <-  subset(cb, cb[,3]==1)
	cb2 <-  subset(cb, cb[,3]>=3)
	text(cb1[,4], cb1[,5], rownames(cb1),cex=font_size,offset=0,col="black",)
	library(ade4)
	s.label_my(
		cb2,
		xax=4,
		yax=5,
		label=rownames(cb2),
		boxes=T,
		clabel=font_size,
		addaxes=F,
		include.origin=F,
		grid=F,
		cpoint=0,
		cneig=0,
		cgrid=0,
		add.plot=T,
	)
	if (resize_vars == 0){
		points(cb2[,1], cb2[,2], pch=c(20,1,0,2,4:15)[cb2[,3]], col="gray30")
	}
	if ( is.null(segs) == F){
		for (i in 1:nrow(segs) ){
			segments(
				segs[i,1],segs[i,2],segs[i,3],segs[i,4],
				col="gray60",
				lwd=1
			)
		}
	}
} else if (plot_mode == "vars") {
	cb  <- cbind(cb, labcd$x, labcd$y)
	cb2 <-  subset(cb, cb[,3]>=3)
	text(
		cb2[,4],
		cb2[,5],
		rownames(cb2),
		cex=font_size,
		offset=0,
		col=col_txt_vars
	)
} else if (plot_mode == "color") {
	text(
		labcd$x,
		labcd$y,
		rownames(cb),
		cex=font_size,
		offset=0,
		col=c(col_txt_words,NA,rep(col_txt_vars,v_count) )[cb[,3]]
	)
	if ( is.null(segs) == F){
		for (i in 1:nrow(segs) ){
			segments(
				segs[i,1],segs[i,2],segs[i,3],segs[i,4],
				col="gray60",
				lwd=1
			)
		}
	}
}


';
}

sub r_command_bubble_v{
	return '

if (plot_mode == "color"){
	col_txt_words <- "black"
	col_txt_vars  <- "#DC143C"
	col_dot_words <- "#00CED1"
	col_dot_vars  <- "#FF6347"
}

if (plot_mode == "gray"){
	col_txt_words <- "black"
	col_txt_vars  <- "black"
	col_dot_words <- "gray55"
	col_dot_vars  <- "gray30"
}

if (plot_mode == "vars"){
	col_txt_words <- NA
	col_txt_vars  <- "black"
	col_dot_words <- "#ADD8E6"
	col_dot_vars  <- "red"
}

if (plot_mode == "dots"){
	col_txt_words <- NA
	col_txt_vars  <- NA
	col_dot_words <- "black"
	col_dot_vars  <- "black"
}

# Bubble size
neg_to_zero <- function(nums){
  temp <- NULL
  for (i in 1:length(nums) ){
    if (nums[i] < 1){
      temp[i] <- 1
    } else {
      temp[i] <-  nums[i]
    }
  }
  return(temp)
}

b_size <- NULL
for (i in rownames(c$cscore)){
	if ( is.na(i) || is.null(i) || is.nan(i) ){
		b_size <- c( b_size, 1 )
	} else {
		b_size <- c( b_size, sum( d[,i] ) )
	}
}

b_size <- sqrt( b_size / pi ) # adjust bubble size: frequency ratio = square measure ratio

if (std_radius){ # standardize (enphasize) bubble size
	if ( sd(b_size) == 0 ){
		b_size <- rep(10, length(b_size))
	} else {
		b_size <- b_size / sd(b_size)
		b_size <- b_size - mean(b_size)
		b_size <- b_size * 5 * bubble_var / 100 + 10
		b_size <- neg_to_zero(b_size)
	}
}

# set plot area
plot(
	rbind(
		cbind(c$cscore[,d_x], c$cscore[,d_y], ptype),
		cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch)
	),
	pch=NA,
	col="black",
	xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),
	ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),
	#bty="l"
)

# draw bubbles of words
symbols(
	c$cscore[,d_x],
	c$cscore[,d_y],
	circles=b_size,
	inches=0.5 * bubble_size / 100,
	fg=c(col_dot_words,"#ADD8E6")[ptype],
	add=T,
)

# draw bubbles of variables
if (biplot){
	# bubble size
	if (resize_vars){
		pch_cex <- sqrt(n_total);
		pch_cex <- pch_cex * ( 10 / max(pch_cex) )
		if (std_radius){ # standardize (enphasize) bubble size
			if ( sd(pch_cex) == 0 ){
				pch_cex <- rep(10,length(pch_cex))
			} else {
				pch_cex <- pch_cex / sd(pch_cex)
				pch_cex <- pch_cex - mean(pch_cex)
				pch_cex <- pch_cex * 5 + 10
				pch_cex <- neg_to_zero(pch_cex)
				pch_cex <- pch_cex * ( 10 / max(pch_cex) )
			}
		}
		pch_cex <- pch_cex * bubble_size / 100
	}
	# plot points of variables
	points(
		cbb <- cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch),
		pch=c(20,1,0,2,4:15)[cbb[,3]],
		col=c("#66CCCC","#ADD8E6",rep( col_dot_vars, v_count ))[cbb[,3]],
		cex=pch_cex,
	)
}

# compute label positions
if (biplot){
	cb <- rbind(
		cbind(c$cscore[,d_x], c$cscore[,d_y], ptype),
		cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch)
	)
} else {
	cb <- cbind(c$cscore[,d_x], c$cscore[,d_y], ptype)
}

if ( T ){
	library(maptools)
	labcd <- pointLabel(
		x=c$rscore[,d_x],
		y=c$rscore[,d_y],
		labels=rownames(c$rscore),
		cex=1,
		offset=0,
		doPlot=F
		)


	#labcd <- pointLabel(
	#	x=cb[,1],
	#	y=cb[,2],
	#	labels=rownames(cb),
	#	cex=font_size,
	#	offset=0,
	#	doPlot=F
	#)

	xorg <- c$rscore[,d_x]
	yorg <- c$rscore[,d_y]
	#cex  <- 1

	library(wordcloud)
	nc <- wordlayout(
		labcd$x,
		labcd$y,
		rownames(c$rscore),
		cex=cex * 1.25,
		xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
		ylim=c(  par( "usr" )[3], par( "usr" )[4] )
	)

	xlen <- par("usr")[2] - par("usr")[1]
	ylen <- par("usr")[4] - par("usr")[3]

	segs <- NULL
	for (i in 1:length( rownames(c$rscore) ) ){
		x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
		y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
		dst <- sqrt( x^2 + y^2 )
		print(dst)
		if ( dst > 0.05 ){
			segs <- rbind(
				segs,
				c(
					nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
					xorg[i], yorg[i]
				) 
			)
			#segments(
			#	nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
			#	xorg[i], yorg[i],
			#	col="gray60",
			#	lwd=1
			#)
			
		}
	}

	xorg <- labcd$x
	yorg <- labcd$y
	labcd$x <- nc[,1] + .5 * nc[,3]
	labcd$y <- nc[,2] + .5 * nc[,4]


}

# draw labels
if (plot_mode == "gray"){
	cb  <- cbind(cb, labcd$x, labcd$y)
	cb1 <-  subset(cb, cb[,3]==1)
	cb2 <-  subset(cb, cb[,3]>=3)
	text(cb1[,4], cb1[,5], rownames(cb1),cex=font_size,offset=0,col="black",)
	library(ade4)
	s.label_my(
		cb2,
		xax=4,
		yax=5,
		label=rownames(cb2),
		boxes=T,
		clabel=font_size,
		addaxes=F,
		include.origin=F,
		grid=F,
		cpoint=0,
		cneig=0,
		cgrid=0,
		add.plot=T,
	)
	if (resize_vars == 0){
		points(cb2[,1], cb2[,2], pch=c(20,1,0,2,4:15)[cb2[,3]], col="gray30")
	}
	if ( is.null(segs) == F){
		for (i in 1:nrow(segs) ){
			segments(
				segs[i,1],segs[i,2],segs[i,3],segs[i,4],
				col="gray60",
				lwd=1
			)
		}
	}
} else if (plot_mode == "vars") {
	cb  <- cbind(cb, labcd$x, labcd$y)
	cb2 <-  subset(cb, cb[,3]>=3)
	text(
		cb2[,4],
		cb2[,5],
		rownames(cb2),
		cex=font_size,
		offset=0,
		col=col_txt_vars
	)
} else if (plot_mode == "color") {
	text(
		labcd$x,
		labcd$y,
		rownames(cb),
		cex=font_size,
		offset=0,
		col=c(col_txt_words,NA,rep(col_txt_vars,v_count) )[cb[,3]]
	)
	if ( is.null(segs) == F){
		for (i in 1:nrow(segs) ){
			segments(
				segs[i,1],segs[i,2],segs[i,3],segs[i,4],
				col="gray60",
				lwd=1
			)
		}
	}
}


';
}



sub r_command_slab_my{
	return '
# configure the slab function
s.label_my <- function (dfxy, xax = 1, yax = 2, label = row.names(dfxy),
    clabel = 1, 
    pch = 20, cpoint = if (clabel == 0) 1 else 0, boxes = TRUE, 
    neig = NULL, cneig = 2, xlim = NULL, ylim = NULL, grid = TRUE, 
    addaxes = TRUE, cgrid = 1, include.origin = TRUE, origin = c(0, 
        0), sub = "", csub = 1.25, possub = "bottomleft", pixmap = NULL, 
    contour = NULL, area = NULL, add.plot = FALSE) 
{
    dfxy <- data.frame(dfxy)
    opar <- par(mar = par("mar"))
    on.exit(par(opar))
    par(mar = c(0.1, 0.1, 0.1, 0.1))
    coo <- scatterutil.base(dfxy = dfxy, xax = xax, yax = yax, 
        xlim = xlim, ylim = ylim, grid = grid, addaxes = addaxes, 
        cgrid = cgrid, include.origin = include.origin, origin = origin, 
        sub = sub, csub = csub, possub = possub, pixmap = pixmap, 
        contour = contour, area = area, add.plot = add.plot)
    if (!is.null(neig)) {
        if (is.null(class(neig))) 
            neig <- NULL
        if (class(neig) != "neig") 
            neig <- NULL
        deg <- attr(neig, "degrees")
        if ((length(deg)) != (length(coo$x))) 
            neig <- NULL
    }
    if (!is.null(neig)) {
        fun <- function(x, coo) {
            segments(coo$x[x[1]], coo$y[x[1]], coo$x[x[2]], coo$y[x[2]], 
                lwd = par("lwd") * cneig)
        }
        apply(unclass(neig), 1, fun, coo = coo)
    }
    if (clabel > 0) 
        scatterutil.eti_my(coo$x, coo$y, label, clabel, boxes)
    if (cpoint > 0 & clabel < 1e-06) 
        points(coo$x, coo$y, pch = pch, cex = par("cex") * cpoint)
    #box()
    invisible(match.call())
}
scatterutil.eti_my <- function (x, y, label, clabel, boxes = TRUE, coul = rep(1, length(x)), 
    horizontal = TRUE) 
{
    if (length(label) == 0) 
        return(invisible())
    if (is.null(label)) 
        return(invisible())
    if (any(label == "")) 
        return(invisible())
    cex0 <- par("cex") * clabel
    for (i in 1:(length(x))) {
        cha <- as.character(label[i])
        cha2 <- paste( " ", cha, " ", sep = "")
        x1 <- x[i]
        y1 <- y[i]
        xh <- strwidth(cha2, cex = cex0)
        yh <- strheight(cha, cex = cex0) * 5/3
        if (!horizontal) {
            tmp <- scatterutil.convrot90(xh, yh)
            xh <- tmp[1]
            yh <- tmp[2]
        }
        if (boxes) {
            rect(x1 - xh/2, y1 - yh/2, x1 + xh/2, y1 + yh/2, 
                col = "white", border = coul[i])
        }
        if (horizontal) {
            text(x1, y1, cha, cex = cex0, col = coul[i])
            print("looks ok...")
        }
        else {
            text(x1, y1, cha, cex = cex0, col = coul[i], srt = 90)
        }
    }
}
';

}
#--------------#
#   ��������   #


sub label{
	return kh_msg->get('win_title'); # ��и졦�б�ʬ�ϡ����ץ����
}

sub win_name{
	return 'w_word_corresp';
}

sub min{
	my $self = shift;
	return $self->{words_obj}->min;
}
sub max{
	my $self = shift;
	return $self->{words_obj}->max;
}
sub min_df{
	my $self = shift;
	return $self->{words_obj}->min_df;
}
sub max_df{
	my $self = shift;
	return $self->{words_obj}->max_df;
}
sub tani{
	my $self = shift;
	return $self->{words_obj}->tani;
}
sub hinshi{
	my $self = shift;
	return $self->{words_obj}->hinshi;
}



1;