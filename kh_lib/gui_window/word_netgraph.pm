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
		-label => 'Words',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1, -side => 'left');

	$lf_w->Label(
		-text => gui_window->gui_jchar('������ñ�̤ȸ������'),
		-font => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w', -pady => 2);

	$self->{words_obj} = gui_widget::words->open(
		parent => $lf_w,
		tani_command => sub{
			if ($self->{var_obj}){
				$self->{var_obj}->new_tani($self->tani);
			}
		},
		verb   => '����',
	);

	my $lf = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0);

	$lf->Label(
		-text => $self->gui_jchar('�������ͥåȥ���ξܺ�����'),
		-font => "TKFN",
		-foreground => 'blue'
	)->pack(-anchor => 'w', -pady => 2);

	# �����ط��μ���
	$lf->Label(
		-text => $self->gui_jchar('�����ط���edge�ˤμ���'),
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
		-text             => $self->gui_jchar('�� �� ��'),
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
		-text             => $self->gui_jchar('�� �� �����ѿ������Ф�'),
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
		-text => $self->gui_jchar('�����ѿ������Ф���'),
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{var_obj} = gui_widget::select_a_var->open(
		parent        => $f6,
		tani          => $self->tani,
		show_headings => 1,
	);

	# Edge����
	$lf->Label(
		-text => $self->gui_jchar('���褹�붦���ط���edge�ˤιʤ����'),
		-font => "TKFN",
	)->pack(-anchor => 'w');

	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 2
	);

	$f4->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{radio} = 'n';
	$f4->Radiobutton(
		-text             => $self->gui_jchar('�������'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 'n',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w', -side => 'left');

	$self->{entry_edges_number} = $f4->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_edges_number}->insert(0,'60');
	$self->{entry_edges_number}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_edges_number});

	$f4->Radiobutton(
		-text             => $self->gui_jchar('Jaccard������'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 'j',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w', -side => 'left');

	$self->{entry_edges_jac} = $f4->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_edges_jac}->insert(0,'0.2');
	$self->{entry_edges_jac}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_edges_jac});

	$f4->Label(
		-text => $self->gui_jchar('�ʾ�'),
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	# Edge��������Node���礭��
	$lf->Checkbutton(
			-text     => $self->gui_jchar('���������ط��ۤ�������������','euc'),
			-variable => \$self->{check_use_weight_as_width},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$self->{wc_use_freq_as_size} = $lf->Checkbutton(
			-text     => $self->gui_jchar('�и�����¿����ۤ��礭���ߤ�����','euc'),
			-variable => \$self->{check_use_freq_as_size},
			-anchor   => 'w',
			-command  => sub{
				$self->{check_smaller_nodes} = 0;
				$self->refresh(3);
			},
	)->pack(-anchor => 'w');

	my $fontsize_frame = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 0,
		-padx => 0,
	);

	$fontsize_frame->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');
	
	$self->{wc_use_freq_as_fsize} = $fontsize_frame->Checkbutton(
			-text     => $self->gui_jchar('�ե���Ȥ��礭�� ��EMF��EPS�Ǥν��ϡ���������','euc'),
			-variable => \$self->{check_use_freq_as_fsize},
			-anchor => 'w',
			-state => 'disabled',
	)->pack(-anchor => 'w');

	$self->{wc_smaller_nodes} = $lf->Checkbutton(
			-text     => $self->gui_jchar('���٤Ƥθ�򾮤���αߤ�����','euc'),
			-variable => \$self->{check_smaller_nodes},
			-anchor   => 'w',
			-command  => sub{
				$self->{check_use_freq_as_size} = 0;
				$self->refresh(3);
			},
	)->pack(-anchor => 'w');

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
			-text     => $self->gui_jchar('�¹Ի��ˤ��β��̤��Ĥ��ʤ�','euc'),
			-variable => \$self->{check_rm_open},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->close;}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{$self->calc;},
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');

	$self->refresh(3);
	return $self;
}

sub refresh{
	my $self = shift;

	my (@dis, @nor);
	if ($self->{radio} eq 'n'){
		push @nor, $self->{entry_edges_number};
		push @dis, $self->{entry_edges_jac};
	} else {
		push @nor, $self->{entry_edges_jac};
		push @dis, $self->{entry_edges_number};
	}

	if ($self->{check_use_freq_as_size}){
		push @nor, $self->{wc_use_freq_as_fsize};
		push @dis, $self->{wc_smaller_nodes};
	} else {
		push @dis, $self->{wc_use_freq_as_fsize};
		push @nor, $self->{wc_smaller_nodes};
	}

	if ($self->{check_smaller_nodes}){
		push @dis, $self->{wc_use_freq_as_size};
		push @dis, $self->{wc_use_freq_as_fsize};
	} else {
		push @nor, $self->{wc_use_freq_as_size};
	}

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

	if ($check_num < 5){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���ʤ��Ȥ�5�İʾ����и�����򤷤Ʋ�������',
		);
		return 0;
	}

	if ($check_num > 300){
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
					 '���ߤ�����Ǥ�'.$check_num.'�줬ʬ�Ϥ����Ѥ���ޤ���'
					."\n"
					.'ʬ�Ϥ��Ѥ����ο���100��150���٤ˤ������뤳�Ȥ�侩���ޤ���'
					."\n"
					.'³�Ԥ��Ƥ�����Ǥ�����'
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
		$r_command .= &r_command_concat;
	}

	# �ǡ�������
	$r_command .= "d <- t(d)\n";
	$r_command .= "# END: DATA\n";

	use plotR::network;
	my $plotR = plotR::network->new(
		edge_type        => $self->gui_jg( $self->{radio_type} ),
		font_size         => $self->{font_obj}->font_size,
		font_bold         => $self->{font_obj}->check_bold_text,
		plot_size         => $self->{font_obj}->plot_size,
		n_or_j           => $self->gui_jg( $self->{radio} ),
		edges_num        => $self->gui_jg( $self->{entry_edges_number}->get ),
		edges_jac        => $self->gui_jg( $self->{entry_edges_jac}->get ),
		use_freq_as_size => $self->gui_jg( $self->{check_use_freq_as_size} ),
		use_freq_as_fsize=> $self->gui_jg( $self->{check_use_freq_as_fsize} ),
		smaller_nodes    => $self->gui_jg( $self->{check_smaller_nodes} ),
		use_weight_as_width =>
			$self->gui_jg( $self->{check_use_weight_as_width} ),
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
		no_geometry => 1,
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
	return '��и졦�����ͥåȥ�������ץ����';
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
	v0 != "��»��" & v0 != "." & v0 != "missing"
)
v0 <- NULL
v1 <- NULL

d <- t(d)
d <- subset(
	d,
	rownames(d) != "<>��»��" & rownames(d) != "<>." & rownames(d) != "<>missing"
)
d <- t(d)

';
}

1;