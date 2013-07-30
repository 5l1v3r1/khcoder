package gui_window::cod_corresp;
use base qw(gui_window);

use strict;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt(kh_msg->get('win_title'))); # �����ǥ��󥰡��б�ʬ�ϡ����ץ����

	my $lf = $win->LabFrame(
		-label => 'Codes',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 0, -side => 'left',-anchor => 'w');

	my $rf = $win->Frame()
		->pack(-fill => 'both', -expand => 1);

	my $lf2 = $rf->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);


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
		-text => kh_msg->get('coding_unit'), # �����ǥ���ñ�̡�
		-font => "TKFN",
	)->pack(-side => 'left');
	my %pack1 = (
		-anchor => 'w',
		-padx => 2,
		-pady => 2,
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f1,
		command => sub { $self->refresh; },
		pack   => \%pack1,
	);

	# ����������
	$lf->Label(
		-text => kh_msg->get('select_codes'), # ����������
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 0);

	my $f2 = $lf->Frame()->pack(
		-fill   => 'both',
		-expand => 1,
		-padx   => 2,
		-pady   => 2
	);

	$f2->Label(
		-text => '    ',
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
		-text => kh_msg->gget('all'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{$self->select_all;}
	)->pack(-pady => 3);
	$f2_2->Button(
		-text => kh_msg->gget('clear'),,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{$self->select_none;}
	)->pack();

	$lf->Label(
		-text => kh_msg->get('sel3'), # �����������ɤ�3�İʾ����򤷤Ʋ�������
		-font => "TKFN",
	)->pack(
		-anchor => 'w',
		-padx   => 4,
		-pady   => 2,
	);

	# ���ϥǡ���������
	$lf2->Label(
		-text => kh_msg->get('matrix_type'), # ʬ�Ϥ˻��Ѥ���ǡ���ɽ�μ��ࡧ
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 0);

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

	$self->{radio} = 1;
	#$fi_1->Radiobutton(
	#	-text             => kh_msg->get('c_d'), # ������ �� ʸ���Ʊ�����֤ʤ���
	#	-font             => "TKFN",
	#	-variable         => \$self->{radio},
	#	-value            => 0,
	#	-command          => sub{ $self->refresh;},
	#)->pack(-anchor => 'w');

	$fi_1->Radiobutton(
		-text             => kh_msg->get('c_dd'), # ������ �� ��̤ξϡ��ᡦ����
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 1,
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
		-text => kh_msg->get('gui_window::word_corresp->unit'), # ����ñ�̡�
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
	$self->{biplot} = 1;
	$self->{label_high2} = $fi_4->Checkbutton(
		-text     => kh_msg->get('gui_window::word_corresp->biplot'), # ���Ф��ޤ���ʸ���ֹ��Ʊ������
		-variable => \$self->{biplot},
	)->pack(
		-anchor => 'w',
		-side  => 'left',
	);

	$fi_1->Radiobutton(
		-text             => kh_msg->get('c_v'), # ������ �� �����ѿ�
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 2,
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $fi_3 = $fi_1->Frame()->pack(
		-anchor => 'w',
		-fill   => 'both',
		-expand => 1,
	);
	$self->{label_var} = $fi_3->Label(
		-text => '    ',
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);
	$self->{opt_frame_var} = $fi_3;

	# ���ۤθ����ʸ�Τ�ʬ��
	my $fsw = $lf2->Frame()->pack(
		-fill => 'x',
		-pady => 2,
	);

	$self->{check_filter_w} = 1;
	$self->{check_filter_w_widget} = $fsw->Checkbutton(
		-text     => kh_msg->get('flw'), # ���ۤ������ʥ����ɤ�ʬ�Ϥ˻��ѡ�
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
	$self->{entry_flw}->insert(0,'50');
	$self->{entry_flw}->bind("<Key-Return>",sub{$self->_calc;});
	$self->{entry_flw}->bind("<KP_Enter>",sub{$self->_calc;});
	$self->config_entry_focusin($self->{entry_flw});

	$self->refresh_flw;

	# ��ħŪ�ʸ�Τߥ�٥�ɽ��
	my $fs = $lf2->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 2,
	);

	$fs->Checkbutton(
		-text     => kh_msg->get('flt'), # ��������Υ�줿�����ɤΤߥ�٥�ɽ����
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
	$self->{entry_flt}->insert(0,'50');
	$self->{entry_flt}->bind("<Key-Return>",sub{$self->_calc;});
	$self->{entry_flt}->bind("<KP_Enter>",sub{$self->_calc;});
	$self->config_entry_focusin($self->{entry_flt});

	$self->refresh_flt;

	$self->refresh;

	# �Х֥�ץ�å�
	$self->{bubble_obj} = gui_widget::bubble->open(
		parent       => $lf2,
		type         => 'corresp',
		command      => sub{ $self->_calc; },
		pack    => {
			-anchor   => 'w',
		},
	);

	# ��ʬ
	$self->{xy_obj} = gui_widget::r_xy->open(
		parent    => $lf2,
		command   => sub{ $self->_calc; },
		pack      => { -anchor => 'w', -pady => 2 },
	);

	# �ե���ȥ�����
	$self->{font_obj} = gui_widget::r_font->open(
		parent    => $lf2,
		command   => sub{ $self->_calc; },
		pack      => { -anchor   => 'w' },
		font_size => $::config_obj->r_default_font_size,
		show_bold => 0,
		plot_size => 480,
	);

	$rf->Checkbutton(
			-text     => kh_msg->gget('r_dont_close'),
			-variable => \$self->{check_rm_open},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	# OK������󥻥�
	my $f3 = $rf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);

	$f3->Button(
		-text => kh_msg->gget('cancel'),
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->withd;}
	)->pack(-side => 'right',-padx => 2);

	$self->{ok_btn} = $f3->Button(
		-text => kh_msg->gget('ok'),
		-width => 8,
		-font => "TKFN",
		-state => 'disable',
		-command => sub{$self->_calc;}
	)->pack(-side => 'right');
	$self->{ok_btn}->focus;

	$self->read_cfile;

	return $self;
}

# ����ħ������ܡפΥ����å��ܥå���
sub refresh_flt{
	my $self = shift;
	if ( $self->{check_filter} ){
		$self->{entry_flt}   ->configure(-state => 'normal');
		$self->{entry_flt_l1}->configure(-state => 'normal');
	} else {
		$self->{entry_flt}   ->configure(-state => 'disabled');
		$self->{entry_flt_l1}->configure(-state => 'disabled');
	}
	return $self;
}

sub refresh_flw{
	my $self = shift;
	if ( $self->{check_filter_w} ){
		$self->{entry_flw}   ->configure(-state => 'normal');
		$self->{entry_flw_l1}->configure(-state => 'normal');
	} else {
		$self->{entry_flw}   ->configure(-state => 'disabled');
		$self->{entry_flw_l1}->configure(-state => 'disabled');
	}
	return $self;
}

sub refresh_same_doc_unit{
	my $self = shift;
	if ( $self->tani eq $self->{high} ){
		$self->{check_filter_w_widget}->configure(-state => 'disabled');
		$self->{entry_flw}   ->configure(-state => 'disabled');
		$self->{entry_flw_l1}->configure(-state => 'disabled');
	} else {
		$self->{check_filter_w_widget}->configure(-state => 'normal');
		$self->refresh_flw;
	}
}


# �饸���ܥ����Ϣ
sub refresh{
	my $self = shift;
	unless ($self->{tani_obj}){return 0;}

	#------------------------#
	#   �����ѿ�����Widget   #

	unless ($self->{last_tani} eq $self->tani){
		if ($self->{opt_body_var}){
			$self->{opt_body_var}->destroy;
		}

		# ���ѤǤ����ѿ�������å�
		my %tani_check = ();
		foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
			$tani_check{$i} = 1;
			last if ($self->tani eq $i);
		}
		# ���첿������ 2011 06/16
		#if ($self->tani eq 'bun'){
		#	%tani_check = ();
		#	$tani_check{'bun'} = 1;
		#}
		
		$self->{last_tani} = $self->tani;
		
		my $h = mysql_outvar->get_list;
		my @options = ();
		foreach my $i (@{$h}){
			if ($tani_check{$i->[0]}){
				push @options, [$self->gui_jchar($i->[1]), $i->[2]];
				#print "varid: $i->[2]\n";
			}
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

	#------------------------------#
	#   ��̤�ʸ��ñ������Widget   #

		my @tanis   = ();
		if ($self->{opt_body_high}){
			$self->{opt_body_high}->destroy;
		}

		my %tani_name = (
			"bun" => kh_msg->gget('sentence'), # ʸ
			"dan" => kh_msg->gget('paragraph'), # ����
			"h5"  => "H5",
			"h4"  => "H4",
			"h3"  => "H3",
			"h2"  => "H2",
			"h1"  => "H1",
		);

		@tanis = ();
		my $if_old_v_is_valid = 0;
		foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
			if (
				mysql_exec->select(
					"select status from status where name = \'$i\'",1
				)->hundle->fetch->[0]
			){
				# �����ǥ���ñ�̤���ʸ�פξ�硢�������ñ�̤Ǥν��פ��Բ�
				if (
					   $i eq 'dan'
					&& $self->tani eq 'bun'
					&& @tanis
				) {
					next;
				}
				
				push @tanis, [ $tani_name{$i}, $i ];
				$if_old_v_is_valid = 1 if $i eq $self->{high};
			}
			last if ($self->tani eq $i);
		}
		$self->{high} = undef unless $if_old_v_is_valid;

		if (@tanis){
			$self->{opt_body_high} = gui_widget::optmenu->open(
				parent  => $self->{opt_frame_high},
				pack    => {-side => 'left', -padx => 2},
				options => \@tanis,
				variable => \$self->{high},
				command => sub{$self->refresh_same_doc_unit;},
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
	}

	#----------------------------------#
	#   Widget��ͭ����̵�����ڤ��ؤ�   #

	if ($self->{radio} == 0){
		$self->{opt_body_high}->configure(-state => 'disable');
		$self->{label_high}->configure(-foreground => 'gray');
		
		$self->{opt_body_var}->disable;
		
		$self->{check_filter_w_widget}->configure(-state => 'disabled');
		$self->{entry_flw}   ->configure(-state => 'disabled');
		$self->{entry_flw_l1}->configure(-state => 'disabled');
	}
	elsif ($self->{radio} == 1){
		if ($self->{opt_body_high_ok}){
			$self->{opt_body_high}->configure(-state => 'normal');
		} else {
			$self->{opt_body_high}->configure(-state => 'disable');
		}
		$self->{label_high}->configure(-foreground => 'black');
		
		$self->{opt_body_var}->disable;

		$self->{check_filter_w_widget}->configure(-state => 'normal');
		$self->{label_high2}->configure(-state => 'normal');
		$self->refresh_flw;
		$self->refresh_flt;
		
		$self->refresh_same_doc_unit;
		#$self->{entry_flw}   ->configure(-state => 'normal');
		#$self->{entry_flw_l1}->configure(-state => 'normal');
	}
	elsif ($self->{radio} == 2){
		$self->{opt_body_high}->configure(-state => 'disable');
		$self->{label_high2}->configure(-state => 'disable');
		$self->{label_high}->configure(-foreground => 'gray');

		$self->{opt_body_var}->enable;
		gui_hlist->update4scroll( $self->{opt_body_var}{hlist} );

		$self->{check_filter_w_widget}->configure(-state => 'normal');
		$self->refresh_flw;
		#$self->{entry_flw}   ->configure(-state => 'normal');
		#$self->{entry_flw_l1}->configure(-state => 'normal');
	}
	
	return 1;
}

# �����ǥ��󥰥롼�롦�ե�������ɤ߹���
sub read_cfile{
	my $self = shift;
	
	$self->{hlist}->delete('all');
	
	unless (-e $self->cfile ){
		return 0;
	}
	
	my $cod_obj = kh_cod::func->read_file($self->cfile);
	
	unless (eval(@{$cod_obj->codes})){
		return 0;
	}

	my $left = $self->{hlist}->ItemStyle('window',-anchor => 'w');

	my $row = 0;
	$self->{checks} = undef;
	foreach my $i (@{$cod_obj->codes}){
		
		$self->{checks}[$row]{check} = 1;
		$self->{checks}[$row]{name}  = $i->name; # ������ 2010 12/24
		
		my $c = $self->{hlist}->Checkbutton(
			-text     => gui_window->gui_jchar($i->name,'euc'),
			-variable => \$self->{checks}[$row]{check},
			-command  => sub{ $self->check_selected_num; },
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
	
	$self->check_selected_num;
	
	return $self;
}

sub start_raise{
	my $self = shift;
	
	# ������������ɤ߼��
	my %selection = ();
	foreach my $i (@{$self->{checks}}){
		if ($i->{check}){
			$selection{$i->{name}} = 1;
		} else {
			$selection{$i->{name}} = -1;
		}
	}
	
	# �롼��ե��������ɤ߹���
	$self->read_cfile;
	
	# �����Ŭ��
	foreach my $i (@{$self->{checks}}){
		if ($selection{$i->{name}} == 1 || $selection{$i->{name}} == 0){
			$i->{check} = 1;
		} else {
			$i->{check} = 0;
		}
	}
	
	$self->{hlist}->update;
	return 1;
}


# �����ɤ�3�İʾ����򤵤�Ƥ��뤫�����å�
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

# �ץ�åȺ�����ɽ��
sub _calc{
	my $self = shift;

	#if ( $self->{radio} == 1 ){
	#	if ( $self->tani eq $self->{high} ){
	#		# ���ξ��Ͼ�̸��Ф���������ʤ�
	#		$self->{radio} = 0;
	#	}
	#}

	my @selected = ();
	foreach my $i (@{$self->{checks}}){
		push @selected, $i->{name} if $i->{check};
	}

	my $vars;
	if ($self->{radio} == 2){
		$vars = $self->{opt_body_var}->selected;
		unless ( @{$vars} ){
			gui_errormsg->open(
				type => 'msg',
				msg  => kh_msg->get('gui_window::word_corresp->select_var'), # �����ѿ���1�İʾ����򤷤Ƥ���������
			);
			return 0;
		}
		
		my $tani2 = '';
		foreach my $i (@{$vars}){
			if ($tani2){
				unless (
					$tani2
					eq mysql_outvar::a_var->new(undef,$i)->{tani}
				){
					gui_errormsg->open(
						type => 'msg',
						msg  => kh_msg->get('gui_window::word_corresp->check_var_unit'), # '���ߤνꡢ����ñ�̤��ۤʤ볰���ѿ���Ʊ���˻��Ѥ��뤳�ȤϤǤ��ޤ���',
					);
					return 0;
				}
			} else {
				$tani2 = mysql_outvar::a_var->new(undef,$i)
					->{tani};
			}
		}
	}

	my $d_x = $self->{xy_obj}->x;
	my $d_y = $self->{xy_obj}->y;

	my $wait_window = gui_wait->start;

	# �ǡ�������
	my $r_command = '';
	unless ( $r_command =  kh_cod::func->read_file($self->cfile)->out2r_selected($self->tani,\@selected) ){ # ������ 2010 12/24
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => kh_msg->get('er_zero'), # �и�����0�Υ����ɤ����ѤǤ��ޤ���
		);
		#$self->close();
		$wait_window->end(no_dialog => 1);
		return 0;
	}

	# �ǡ�������
	$r_command .= "\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "row.names(d) <- c(";
	foreach my $i (@{$self->{checks}}){
		my $name = $i->{name};
		if (index($name,'��') == 0){
			substr($name, 0, 2) = '';
		}
		elsif (index($name,'*') == 0){
			substr($name, 0, 1) = ''
		}
		$r_command .= '"'.$name.'",'
			if $i->{check}
		;
	}
	chop $r_command;
	$r_command .= ")\n";
	$r_command .= "d <- t(d)\n";
	
	# ��̸��Ф�����Ϳ
	if ($self->{radio} == 1){
		my $tani_low  = $self->tani;
		my $tani_high = $self->{high};
		
		unless ($tani_high){
			gui_errormsg->open(
				type   => 'msg',
				window  => \$self->win_obj,
				msg    => kh_msg->get('er_unit'), # ����ñ�̤����������Ǥ���
			);
			return 0;
		}
		
		my $sql = '';
		if ($tani_low eq $tani_high){
			$sql .= "SELECT $tani_high.id\n";
			$sql .= "FROM $tani_high\n";
			$sql .= "ORDER BY $tani_high.id\n";
		} else {
			$sql .= "SELECT $tani_high.id\n";
			$sql .= "FROM $tani_high, $tani_low\n";
			$sql .= "WHERE\n";
			my $n = 0;
			foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
				$sql .= "AND " if $n;
				$sql .= "$tani_low.$i"."_id = $tani_high.$i"."_id\n";
				++$n;
				if ($i eq $tani_high){
					last;
				}
			}
			$sql .= "ORDER BY $tani_low.id\n";
		}
		
		
		my $max = mysql_exec->select("SELECT MAX(id) FROM $tani_high",1)
			->hundle->fetch->[0];
		my %names = ();
		my $n = 1;
		my $headings = "hn <- c(";
		while ($n <= $max){
			$names{$n} = Jcode->new(
				mysql_getheader->get($tani_high, $n),
				'sjis'
			)->euc;

			if (length($names{$n})){
				$names{$n} =~ s/"/ /g;
				$headings .= "\"$names{$n}\",";
			}

			++$n;
		}
		chop $headings;

		$r_command .= "v <- c(";
		my $h = mysql_exec->select($sql,1)->hundle;
		while (my $i = $h->fetch){
			$r_command .= "$i->[0],";
		}
		chop $r_command;
		$r_command .= ")\n";

		$r_command .= &r_command_aggr_str;

		if ( length($headings) > 7 ){
			$headings .= ")\n";
			#print Jcode->new($headings)->sjis, "\n";
			$r_command .= $headings;
			$r_command .= "d <- as.matrix(d)\n";
			$r_command .= "rownames(d) <- hn[as.numeric( rownames(d) )]\n";
		}
	}

	# �����ѿ�����Ϳ
	$r_command .= "v_count <- 0\n";
	$r_command .= "v_pch   <- NULL\n";
	if ($self->{radio} == 2){
		my $tani = $self->tani;
		
		my $n_v = 0;
		foreach my $i (@{$vars}){
			my $var_obj = mysql_outvar::a_var->new(undef,$i);
			my $sql = '';
			if ( $var_obj->{tani} eq $tani){
				$sql .= "SELECT $var_obj->{column} FROM $var_obj->{table} ";
				$sql .= "ORDER BY id";
			} else {
				$sql .= "SELECT $var_obj->{table}.$var_obj->{column}\n";
				
				$sql .= "FROM $tani\n";
				$sql .= "LEFT JOIN $var_obj->{tani} ON\n";
				my $n = 0;
				foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
					$sql .= "\t";
					$sql .= "and " if $n;
					$sql .= "$var_obj->{tani}.$i"."_id = $tani.$i"."_id\n";
					++$n;
					last if ($var_obj->{tani} eq $i);
				}
				$sql .= "LEFT JOIN $var_obj->{table} ON $var_obj->{tani}.id = $var_obj->{table}.id\n";
				
				#$sql .= "FROM $tani, $var_obj->{tani}, $var_obj->{table}\n";
				#$sql .= "WHERE\n";
				#$sql .= "	$var_obj->{tani}.id = $var_obj->{table}.id\n";
				#foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
				#	$sql .= "	and $var_obj->{tani}.$i"."_id = $tani.$i"."_id\n";
				#	last if ($var_obj->{tani} eq $i);
				#}
				
				$sql .= "ORDER BY $tani.id";
				#print "$sql\n";
			}
		
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
			#print "num1: $n\n";
			chop $r_command;
			$r_command .= ")\n";
			++$n_v;
		}
		$r_command .= &r_command_aggr_var($n_v);
	}
	# �����ѿ���̵���ä����
	$r_command .= '
		if ( length(v_pch) == 0 ) {
			v_pch   <- 3
			v_count <- 1
		}
	';

	# �б�ʬ�ϼ¹ԤΤ����R���ޥ��
	$r_command .= "d <- subset(d, rowSums(d) > 0)\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "d <- subset(d, rowSums(d) > 0)\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "# END: DATA\n";

	my $filter = 0;
	if ( $self->{check_filter} ){
		$filter = $self->gui_jg( $self->{entry_flt}->get );
	}

	my $filter_w = 0;
	if ( $self->{check_filter_w} && $self->{radio} != 0){
		$filter_w = $self->gui_jg( $self->{entry_flw}->get );
	}

	my $biplot = 1;
	if ($self->{radio} == 1){
		$biplot = $self->gui_jg( $self->{biplot} );
	}

	my $plot = &gui_window::word_corresp::make_plot(
		d_x          => $self->{xy_obj}->x,
		d_y          => $self->{xy_obj}->y,
		flt          => $filter,
		flw          => $filter_w,
		biplot       => $biplot,
		font_size         => $self->{font_obj}->font_size,
		font_bold         => $self->{font_obj}->check_bold_text,
		plot_size         => $self->{font_obj}->plot_size,
		r_command    => $r_command,
		plotwin_name => 'cod_corresp',
		bubble       => $self->{bubble_obj}->check_bubble,
		std_radius   => $self->{bubble_obj}->chk_std_radius,
		resize_vars  => $self->{bubble_obj}->chk_resize_vars,
		bubble_size  => $self->{bubble_obj}->size,
		bubble_var   => $self->{bubble_obj}->var,
		use_alpha    => $self->{bubble_obj}->alpha,
	);

	$wait_window->end(no_dialog => 1);

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_cod_corresp_plot')){
		$::main_gui->get('w_cod_corresp_plot')->close;
	}
	
	gui_window::r_plot::cod_corresp->open(
		plots       => $plot,
		#ax          => $self->{ax},
	);

	# �����
	unless ( $self->{radio} ){
		$self->{radio} = 1;
	}
	
	unless ( $self->{check_rm_open} ){
		$self->withd;
	}

}

sub r_command_aggr_var_old{
	my $t = << 'END_OF_the_R_COMMAND';

# aggregate
n_total <- table(v)
d <- aggregate(d,list(name = v), sum)
row.names(d) <- d$name
d$name <- NULL
d       <- d[       order(rownames(d      )), ]
n_total <- n_total[ order(rownames(n_total))  ]
#------------------------------------------------------------------------------
n_total <- subset(
	n_total,
	row.names(d) != "��»��" & row.names(d) != "." & row.names(d) != "missing"
)
d <- subset(
	d,
	row.names(d) != "��»��" & row.names(d) != "." & row.names(d) != "missing"
)
#------------------------------------------------------------------------------
n_total <- subset(n_total,rowSums(d) > 0)

END_OF_the_R_COMMAND
return $t;
}

sub r_command_aggr_var{
	my $n_v = shift;
	my $t = << 'END_OF_the_R_COMMAND';

# aggregate
aggregate_with_var <- function(d, doc_length_mtr, v) {
	d       <- aggregate(d,list(name = v), sum)
	n_total <- as.matrix( table(v) )

	row.names(d) <- d$name
	d$name <- NULL

	d       <- d[       order(rownames(d      )), ]
	n_total <- n_total[ order(rownames(n_total)), ]

	n_total <- subset(
		n_total,
		row.names(d) != "��»��" & row.names(d) != "." & row.names(d) != "missing" & row.names(d) != ""
	)
	d <- subset(
		d,
		row.names(d) != "��»��" & row.names(d) != "." & row.names(d) != "missing" & row.names(d) != ""
	)
	n_total <- as.matrix(n_total)
	return( list(d, n_total) )
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

d       <- dd

n_total <- nn
n_total <- subset(n_total, rowSums(d) > 0)
n_total <- n_total[,1]

END_OF_the_R_COMMAND2

	return $t;
}


sub r_command_aggr_str{
	my $t = << 'END_OF_the_R_COMMAND';

# aggregate
n_total <- table(v)
d <- aggregate(d,list(name = v), sum)
row.names(d) <- d$name
d$name <- NULL
d       <- d[       order(rownames(d      )), ]
n_total <- n_total[ order(rownames(n_total))  ]
n_total <- subset(n_total,rowSums(d) > 0)

END_OF_the_R_COMMAND
return $t;
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
	return 'w_cod_corresp';
}
1;