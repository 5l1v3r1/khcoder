package gui_window::cod_netg;
use base qw(gui_window);

use strict;


#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt(kh_msg->get('win_title'))); # �����ǥ��󥰡������ͥåȥ�������ץ����

	my $lf = $win->LabFrame(
		-label => 'Codes',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 0, -side => 'left',-anchor => 'w');

	#my $rf = $win->Frame()
	#	->pack(-fill => 'both', -expand => 1);

	my $lf2 = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0, -anchor => 'n');

	# �롼�롦�ե�����
	my %pack0 = (
		-anchor => 'w',
		-padx => 2,
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
		-text => kh_msg->get('gui_window::cod_corresp->coding_unit'), # �����ǥ���ñ�̡�
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
		-text => kh_msg->get('gui_window::cod_corresp->select_codes'), # ����������
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
		-text => kh_msg->gget('all'), # ���٤�
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{$self->select_all;}
	)->pack(-pady => 3);
	$f2_2->Button(
		-text => kh_msg->gget('clear'), # ���ꥢ
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{$self->select_none;}
	)->pack();

	$lf->Label(
		-text => kh_msg->get('gui_window::cod_corresp->sel3'), # �����������ɤ�3�İʾ����򤷤Ʋ�������','euc
		-font => "TKFN",
	)->pack(
		-anchor => 'w',
		-padx   => 4,
	);

	# �����ط��μ���
	$lf2->Label(
		-text => kh_msg->get('gui_window::word_netgraph->e_type'), # �����ط���edge�ˤμ���
		-font => "TKFN",
	)->pack(-anchor => 'w');

	my $f5 = $lf2->Frame()->pack(
		-fill => 'x',
		-pady => 1
	);

	$f5->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	unless ( defined( $self->{radio_type} ) ){
		$self->{radio_type} = 'words';
	}

	$f5->Radiobutton(
		-text             => kh_msg->get('c_c'), # �� �� ��
		-font             => "TKFN",
		-variable         => \$self->{radio_type},
		-value            => 'words',
		-command          => sub{ $self->refresh(3);},
	)->pack(-anchor => 'nw', -side => 'left');

	$f5->Label(
		-text => ' ',
		-font => "TKFN",
	)->pack(-anchor => 'nw', -side => 'left');

	$f5->Radiobutton(
		-text             => kh_msg->get('c_v'), # �� �� �����ѿ������Ф�
		-font             => "TKFN",
		-variable         => \$self->{radio_type},
		-value            => 'twomode',
		-command          => sub{ $self->refresh(3);},
	)->pack(-anchor => 'nw');

	my $f6 = $lf2->Frame()->pack(
		-fill => 'x',
		-pady => 1
	);

	$f6->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{var_lab} = $f6->Label(
		-text => kh_msg->get('gui_window::word_netgraph->var'), # �����ѿ������Ф���
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{var_obj} = gui_widget::select_a_var->open(
		parent        => $f6,
		tani          => $self->tani,
		show_headings => 1,
	);

	# �����ͥåȥ���Υ��ץ����
	$self->{net_obj} = gui_widget::r_net->open(
		parent  => $lf2,
		command => sub{ $self->_calc; },
		pack    => { -anchor   => 'w'},
		type    => 'codes',
	);

	# �ե���ȥ�����
	$self->{font_obj} = gui_widget::r_font->open(
		parent    => $lf2,
		command   => sub{ $self->_calc; },
		pack      => { -anchor   => 'w' },
		font_size => $::config_obj->r_default_font_size,
		show_bold => 1,
		plot_size => 480,
	);

	$win->Checkbutton(
			-text     => kh_msg->gget('r_dont_close'), # �¹Ի��ˤ��β��̤��Ĥ��ʤ�','euc
			-variable => \$self->{check_rm_open},
			#-anchor => 'nw',
	)->pack(-anchor => 'nw');

	# OK������󥻥�
	$win->Button(
		-text => kh_msg->gget('cancel'), # ����󥻥�
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->withd;}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$self->{ok_btn} = $win->Button(
		-text => kh_msg->gget('ok'),
		-width => 8,
		-font => "TKFN",
		-state => 'disable',
		-command => sub{$self->_calc;}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');
	$self->{ok_btn}->focus;

	$self->read_cfile;
	$self->refresh(3);

	return $self;
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
		$self->{checks}[$row]{name}  = $i->name;
		
		my $c = $self->{hlist}->Checkbutton(
			-text     => gui_window->gui_jchar($i->name,'euc'),
			-variable => \$self->{checks}[$row]{check},
			-command  => sub{ $self->check_selected_num;},
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

# �����å��ܥå����������ư��
sub refresh{
	my $self = shift;

	my (@dis, @nor);

	if ( $self->{radio_type} eq 'words' ){
		push @dis, $self->{var_lab};
		$self->{var_obj}->disable;
	} else {
		push @nor, $self->{var_lab};
		$self->{var_obj}->enable;
	}


	foreach my $i (@nor){
		$i->configure(-state => 'normal');
	}
	foreach my $i (@dis){
		$i->configure(-state => 'disabled');
	}
	
	$nor[0]->focus unless $_[0] == 3;
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

	my @selected = ();
	foreach my $i (@{$self->{checks}}){
		push @selected, $i->{name} if $i->{check};
	}
	my $selected_num = @selected;
	if ($selected_num < 3){
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => 'error: please select at least 3 codes'
		);
		return 0;
	}

	my $wait_window = gui_wait->start;

	# �ǡ�������
	my $r_command;
	unless ( $r_command =  kh_cod::func->read_file($self->cfile)->out2r_selected($self->tani,\@selected) ){
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => kh_msg->get('gui_window::cod_corresp->er_zero'),
		);
		#$self->close();
		$wait_window->end(no_dialog => 1);
		return 0;
	}

	$r_command .= "\ncolnames(d) <- c(";
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

	# ���Ф��μ��Ф�
	if (
		   $self->{radio_type} eq 'twomode'
		&& $self->{var_obj}->var_id =~ /h[1-5]/
	) {
		my $tani1 = $self->tani;
		my $tani2 = $self->{var_obj}->var_id;
		
		# ���Ф��ꥹ�Ⱥ���
		my $max = mysql_exec->select("SELECT max(id) FROM $tani2")
			->hundle->fetch->[0];
		my %heads = ();
		for (my $n = 1; $n <= $max; ++$n){
			$heads{$n} = Jcode->new(mysql_getheader->get($tani2, $n),'sjis')->euc;
		}

		my $sql = '';
		$sql .= "SELECT $tani2.id\n";
		$sql .= "FROM   $tani1, $tani2\n";
		$sql .= "WHERE \n";
		foreach my $i ("h1","h2","h3","h4","h5"){
			$sql .= " AND " unless $i eq "h1";
			$sql .= "$tani1.$i"."_id = $tani2.$i"."_id\n";
			if ($i eq $tani2){
				last;
			}
		}
		$sql .= "ORDER BY $tani1.id \n";
		
		my $h = mysql_exec->select($sql,1)->hundle;

		$r_command .= "\nv0 <- c(";
		while (my $i = $h->fetch){
			$r_command .= "\"$heads{$i->[0]}\",";
		}
		chop $r_command;
		$r_command .= ")\n";
		
	}

	# �����ѿ��μ��Ф�
	if (
		   $self->{radio_type} eq 'twomode'
		&& $self->{var_obj}->var_id =~ /^[0-9]+$/
	) {
		my $var_obj = mysql_outvar::a_var->new(undef,$self->{var_obj}->var_id);
		
		my $sql = '';
		if ($var_obj->{tani} eq $self->tani){
			$sql .= "SELECT $var_obj->{column} FROM $var_obj->{table} ";
			$sql .= "ORDER BY id";
		} else {
			my $tani1 = $self->tani;
			my $tani2 = $var_obj->{tani};
			$sql .= "SELECT $var_obj->{table}.$var_obj->{column}\n";
			$sql .= "FROM   $tani1, $tani2,$var_obj->{table}\n";
			$sql .= "WHERE \n";
			foreach my $i ("h1","h2","h3","h4","h5"){
				$sql .= " AND " unless $i eq "h1";
				$sql .= "$tani1.$i"."_id = $tani2.$i"."_id\n";
				if ($i eq $tani2){
					last;
				}
			}
			$sql .= " AND $tani2.id = $var_obj->{table}.id \n";
			$sql .= "ORDER BY $tani1.id \n";
		}
		
		$r_command .= "v0 <- c(";
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
	}

	# �����ѿ������Ф��ǡ���������
	if ($self->{radio_type} eq 'twomode'){
		$r_command = Encode::decode('euc-jp',$r_command);
		$r_command .= &r_command_concat;
	}


	# �ǡ�������
	$r_command .= "\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "# END: DATA\n";

	use plotR::network;
	my $plotR = plotR::network->new(
		edge_type        => $self->gui_jg( $self->{radio_type} ),
		font_size        => $self->{font_obj}->font_size,
		font_bold        => $self->{font_obj}->check_bold_text,
		plot_size        => $self->{font_obj}->plot_size,
		n_or_j              => $self->{net_obj}->n_or_j,
		edges_num           => $self->{net_obj}->edges_num,
		edges_jac           => $self->{net_obj}->edges_jac,
		use_freq_as_size    => $self->{net_obj}->use_freq_as_size,
		use_freq_as_fsize   => $self->{net_obj}->use_freq_as_fsize,
		smaller_nodes       => $self->{net_obj}->smaller_nodes,
		use_weight_as_width => $self->{net_obj}->use_weight_as_width,
		min_sp_tree         => $self->{net_obj}->min_sp_tree,
		r_command        => $r_command,
		plotwin_name     => 'cod_netg',
	);

	# �ץ�å�Window�򳫤�
	$wait_window->end(no_dialog => 1);
	
	if ($::main_gui->if_opened('w_cod_netg_plot')){
		$::main_gui->get('w_cod_netg_plot')->close;
	}

	return 0 unless $plotR;

	gui_window::r_plot::cod_netg->open(
		plots       => $plotR->{result_plots},
		msg         => $plotR->{result_info},
		msg_long    => $plotR->{result_info_long},
		#no_geometry => 1,
	);

	$plotR = undef;

	unless ( $self->{check_rm_open} ){
		$self->withd;
	}
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
	return 'w_cod_netg';
}

sub r_command_concat{
	return '
# 1�Ĥγ����ѿ������ä��٥��ȥ��0-1�ޥȥꥯ�����Ѵ�
mk.dummy <- function(dat){
	dat  <- factor(dat)
	cols <- length(levels(dat))
	ret <- NULL
	for (i in 1:length( dat ) ){
		c <- numeric(cols)
		c[as.numeric(dat)[i]] <- 1
		ret <- rbind(ret, c)
	}
	colnames(ret) <- paste( "<>", levels(dat), sep="" )
	rownames(ret) <- NULL
	return(ret)
}
v1 <- mk.dummy(v0)

# ��и�ȳ����ѿ����ܹ�
n_words <- ncol(d)
d <- cbind(d, v1)

d <- subset(
	d,
	v0 != "'
	.kh_msg->get('gui_window::word_corresp->nav') # ��»��
	.'" & v0 != "." & v0 != "missing"
)
v0 <- NULL
v1 <- NULL

d <- t(d)
d <- subset(
	d,
	rownames(d) != "<>'
	.kh_msg->get('gui_window::word_corresp->nav') # ��»��
	.'" & rownames(d) != "<>." & rownames(d) != "<>missing"
)
d <- t(d)

';
}

1;