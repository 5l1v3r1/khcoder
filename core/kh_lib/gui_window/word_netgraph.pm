package gui_window::word_netgraph;
use base qw(gui_window);

use strict;
use Tk;

use gui_widget::tani;
use gui_widget::hinshi;
use mysql_crossout;
use kh_r_plot;

my $bench = 0;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt($self->label));

	my $lf_w = $win->LabFrame(
		-label => kh_msg->get('u_w'), # ����ñ�̤���и������
		-labelside => 'acrosstop',
		-borderwidth => 2,
		-foreground => 'blue'
	)->pack(-fill => 'both', -expand => 1, -side => 'left');

	$self->{words_obj} = gui_widget::words->open(
		parent => $lf_w,
		tani_command => sub{
			if ($self->{var_obj}){
				$self->{var_obj}->new_tani($self->tani);
			}
		},
		verb   => kh_msg->get('use'), # ����
	);

	my $lf = $win->LabFrame(
		-label => kh_msg->get('net_opt'), # �������ͥåȥ��������
		-labelside => 'acrosstop',
		-borderwidth => 2,
		-foreground => 'blue'
	)->pack(-fill => 'x', -expand => 0);

	# �����ط��μ���
	$lf->Label(
		-text => kh_msg->get('e_type'), # �����ط���edge�ˤμ���
		-font => "TKFN",
	)->pack(-anchor => 'w');

	my $f5 = $lf->Frame()->pack(
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
		-text             => kh_msg->get('w_w'), # �� �� ��
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
		-text             => kh_msg->get('w_v'), # �� �� �����ѿ������Ф�
		-font             => "TKFN",
		-variable         => \$self->{radio_type},
		-value            => 'twomode',
		-command          => sub{ $self->refresh(3);},
	)->pack(-anchor => 'nw');

	my $f6 = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 1
	);

	$f6->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{var_lab} = $f6->Label(
		-text => kh_msg->get('var'), # �����ѿ������Ф���
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{var_obj} = gui_widget::select_a_var->open(
		parent        => $f6,
		tani          => $self->tani,
		show_headings => 1,
	);

	# �����ͥåȥ���Υ��ץ����
	$self->{net_obj} = gui_widget::r_net->open(
		parent  => $lf,
		command => sub{ $self->calc; },
		pack    => { -anchor   => 'w'},
	);

	# �ե���ȥ�����
	$self->{font_obj} = gui_widget::r_font->open(
		parent    => $lf,
		command   => sub{ $self->calc; },
		pack      => { -anchor   => 'w' },
		font_size => $::config_obj->r_default_font_size,
		show_bold => 1,
		plot_size => 640,
	);

	$win->Checkbutton(
			-text     => kh_msg->gget('r_dont_close'), # �¹Ի��ˤ��β��̤��Ĥ��ʤ�','euc
			-variable => \$self->{check_rm_open},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$win->Button(
		-text => kh_msg->gget('cancel'), # ����󥻥�
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->close;}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text => kh_msg->gget('ok'),
		-width => 8,
		-font => "TKFN",
		-command => sub{$self->calc;},
	)->pack(-side => 'right', -pady => 2, -anchor => 'se')->focus;

	$self->refresh(3);
	return $self;
}

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
	
	#$nor[0]->focus unless $_[0] == 3;
}

#----------#
#   �¹�   #

sub calc{
	my $self = shift;
	
	# ���ϤΥ����å�
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => kh_msg->get('gui_window::word_corresp->select_pos'), # '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
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

	if ($check_num < 5){
		gui_errormsg->open(
			type => 'msg',
			msg  => kh_msg->get('gui_window::word_mds->select_3words'), # '���ʤ��Ȥ�5�İʾ����и�����򤷤Ʋ�������',
		);
		return 0;
	}

	if ($check_num > 300){
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
					kh_msg->get('gui_window::word_corresp->too_many1') # ���ߤ�����Ǥ�
					.$check_num
					.kh_msg->get('gui_window::word_corresp->too_many2') # �줬���֤���ޤ���
					."\n"
					.kh_msg->get('gui_window::word_corresp->too_many3') # ���֤����ο���100��150���٤ˤ������뤳�Ȥ�侩���ޤ���
					."\n"
					.kh_msg->get('gui_window::word_corresp->too_many4') # ³�Ԥ��Ƥ�����Ǥ�����
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }
	}

	$self->{words_obj}->settings_save;

	my $wait_window = gui_wait->start;

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
		$r_command = $r_command;
		$r_command .= &r_command_concat;
	}

	# �ǡ�������
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
		plotwin_name     => 'word_netgraph',
	);
	
	# �ץ�å�Window�򳫤�
	$wait_window->end(no_dialog => 1);
	
	if ($::main_gui->if_opened('w_word_netgraph_plot')){
		$::main_gui->get('w_word_netgraph_plot')->close;
	}

	return 0 unless $plotR;

	gui_window::r_plot::word_netgraph->open(
		plots       => $plotR->{result_plots},
		msg         => $plotR->{result_info},
		msg_long    => $plotR->{result_info_long},
		#no_geometry => 1,
	);

	$plotR = undef;

	unless ( $self->{check_rm_open} ){
		$self->close;
		undef $self;
	}
	return 1;
}



#--------------#
#   ��������   #

sub label{
	return kh_msg->get('win_title'); # ��и졦�����ͥåȥ�������ץ����
}

sub win_name{
	return 'w_word_netgraph';
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
	.Encode::encode('euc-jp', kh_msg->get('gui_window::word_corresp->nav') ) # ��»��
	.'" & v0 != "." & v0 != "missing"
)
v0 <- NULL
v1 <- NULL

d <- t(d)
d <- subset(
	d,
	rownames(d) != "<>'
	.Encode::encode('euc-jp', kh_msg->get('gui_window::word_corresp->nav')) # ��»��
	.'" & rownames(d) != "<>." & rownames(d) != "<>missing"
)
d <- t(d)

';
}

1;