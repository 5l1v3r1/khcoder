package gui_window::word_ass;
use base qw(gui_window);
use vars qw($filter);

use Tk;
use strict;

use gui_widget::optmenu;
use kh_cod::asso;

my $order_name;

#-------------#
#   GUI����   #
#-------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	#$win->focus;
	$win->title($self->gui_jt('��Ϣ��õ��'));
	#$self->{win_obj} = $win;
	
	#--------------------#
	#   �������ץ����   #
	
	my $lf = $win->LabFrame(
		-label => 'Search Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');

	my $left = $lf->Frame()->pack(-side => 'left', -fill => 'x', -expand => 1);
	my $right = $lf->Frame()->pack(-side => 'right');
	
	# ����������
	$left->Label(
		-text => $self->gui_jchar('������������'),
		-font => "TKFN"
	)->pack(-anchor => 'w');
	
	$self->{clist} = $left->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => '0',
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => '1',
		-padx             => '2',
		-height           => '6',
		-width            => '20',
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-command          => sub{ $self->search; },
		-browsecmd        => sub{ $self->clist_check; },
	)->pack(-anchor => 'w', -padx => '4',-pady => '2', -fill => 'both',-expand => 1);

	# �����ǥ��󥰥롼�롦�ե�����
	my %pack0 = (
			-anchor => 'w',
	);
	$self->{codf_obj} = gui_widget::codf->open(
		parent   => $right,
		command  => sub{$self->read_code;},
		#r_button => 1,
		pack     => \%pack0,
	);

	# ľ�����ϥե졼��
	my $f3 = $right->Frame()->pack(-fill => 'x', -pady => 6);
	$self->{direct_w_l} = $f3->Label(
		-text => $self->gui_jchar('ľ�����ϡ�'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{direct_w_o} = gui_widget::optmenu->open(
		parent  => $f3,
		pack    => {-side => 'left'},
		options =>
			[
				['and'  , 'and' ],
				['or'   , 'or'  ],
				['code' , 'code']
			],
		variable => \$self->{opt_direct},
	);

	$self->{direct_w_e} = $f3->Entry(
		-font       => "TKFN",
	)->pack(-side => 'left', -padx => 2,-fill => 'x',-expand => 1);
	$self->{direct_w_e}->bind(
		"<Key>",
		[\&gui_jchar::check_key_e,Ev('K'),\$self->{direct_w_e}]
	);
	$win->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);
	$self->{direct_w_e}->bind("<Key-Return>",sub{$self->search;});

	# �Ƽ索�ץ����
	my $f2 = $right->Frame()->pack(-fill => 'x',-pady => 2);

	$self->{btn_search} = $f2->Button(
		-font    => "TKFN",
		-text    => $self->gui_jchar('����'),
		-command => sub{ $win->after(10,sub{$self->search;});}
	)->pack(-side => 'right',-padx => 4);
	$win->Balloon()->attach(
		$self->{btn_search},
		-balloonmsg => 'Enter',
		-font       => "TKFN"
	);

	$f2->Label(-text => '   ')->pack(-side => 'right');

	my %pack = (
			-anchor => 'w',
			-pady   => 1,
			-side   => 'right'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f2,
		pack   => \%pack
	);
	$self->{l_c_2} = $f2->Label(
		-text => $self->gui_jchar('����ñ�̡�'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'right');

	$f2->Label(-text => '  ')->pack(-side => 'right');

	$self->{opt_w_method1} = gui_widget::optmenu->open(
		parent  => $f2,
		pack    => {-pady => '1', -side => 'right'},
		options =>
			[
				[$self->gui_jchar('AND����'), 'and'],
				[$self->gui_jchar('OR����') , 'or']
			],
		variable => \$self->{opt_method1},
	);

	#--------------#
	#   �������   #
	
	my $rf = $win->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both',-expand => 'yes',-anchor => 'n');

	$self->{rlist} = $rf->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 6,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-height           => 10,
		-command          => sub {$self->conc;}
	)->pack(-fill =>'both',-expand => 'yes');

	$self->{rlist}->header('create',0,-text => 'N');
	$self->{rlist}->header('create',1,-text => $self->gui_jchar('��и�'));
	$self->{rlist}->header('create',2,-text => $self->gui_jchar('�ʻ�'));
	$self->{rlist}->header('create',3,-text => $self->gui_jchar('����'));
	$self->{rlist}->header('create',4,-text => $self->gui_jchar('����'));
	#$self->{rlist}->header('create',5,-text => $self->gui_jchar('����դ���Ω'));
	$self->{rlist}->header('create',5,-text => $self->gui_jchar(' ������'));

	my $f5 = $rf->Frame()->pack(-fill => 'x', -pady => 2);
	
	$self->{status_label} = $f5->Label(
		-text       => 'Ready.',
		-font       => "TKFN",
		-foreground => 'blue'
	)->pack(-side => 'right');

	$self->{copy_btn} = $f5->Button(
		-font    => "TKFN",
		-text    => $self->gui_jchar('���ԡ�'),
		#-width   => 8,
		-command => sub{ $win->after(10,sub{gui_hlist->copy($self->{rlist});});},
		-borderwidth => 1
	)->pack(-side => 'left');

	$self->win_obj->bind(
		'<Control-Key-c>',
		sub{ $self->{copy_btn}->invoke; }
	);
	$self->win_obj->Balloon()->attach(
		$self->{copy_btn},
		-balloonmsg => 'Ctrl + C',
		-font => "TKFN"
	);

	$f5->Button(
		-font    => "TKFN",
		#-width   => 8,
		-text    => 'KWIC',
		-command => sub{ $win->after(10,sub{$self->conc;});},
		-borderwidth => 1
	)->pack(-side => 'left',-padx => 2);

	$f5->Label(
		-text => $self->gui_jchar(' �����ȡ�'),
		-font => "TKFN",
	)->pack(-side => 'left');

	gui_widget::optmenu->open(
		parent  => $f5,
		pack    => {-side => 'left'},
		options =>
			[
				[$self->gui_jchar('����') ,   'fr'  ],
				[$self->gui_jchar('��Ψ��') , 'sa'  ],
				[$self->gui_jchar('��Ψ��') , 'hi'  ],
				['Jaccard'                  , 'jac' ],
				['Ochiai'                   , 'ochi'],
				#[$self->gui_jchar('��2��') , 'chi'],
			],
		variable => \$self->{opt_order},
		command  => sub{$self->display;}
	)->set_value('jac');

	$order_name = {
		'fr'  => $self->gui_jchar('����'),
		'sa'  => $self->gui_jchar('��Ψ��'),
		'hi'  => $self->gui_jchar('��Ψ��'),
		'jac' => 'Jaccard',
		'ochi'=> 'Ochiai',
	};

	$f5->Label(
		-text => $self->gui_jchar(' '),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{btn_prev} = $f5->Button(
		-text        => $self->gui_jchar('�ե��륿����'),
		-font        => "TKFN",
		-command     =>
			sub{
				gui_window::word_ass_opt->open;
			},
		-borderwidth => 1,
		-state       => 'normal',
	)->pack(-side => 'left',-padx => 2);

	$self->{btn_net} = $f5->Button(
		-text        => $self->gui_jchar('�����ͥå�'),
		-font        => "TKFN",
		-command     =>
			sub{
				$self->net_calc;
			},
		-borderwidth => 1,
		-state       => 'normal',
	)->pack(-side => 'left',-padx => 2);

	$self->win_obj->bind(
		'<Control-Key-n>',
		sub{ $self->{btn_net}->invoke; }
	);
	$self->win_obj->Balloon()->attach(
		$self->{btn_net},
		-balloonmsg => 'Ctrl + N',
		-font => "TKFN"
	);

	$self->{hits_label} = $f5->Label(
		-text       => $self->gui_jchar(' ʸ�����0'),
		-font       => "TKFN",
	)->pack(-side => 'left',);

	$self->win_obj->bind(
		'<FocusIn>',
		sub { $self->activate; }
	);

	#--------------------------#
	#   �ե��륿����ν����   #

	$filter = undef;
	$filter->{limit}   = 75;                   # LIMIT��
	$filter->{min_doc} = 1;                    # ����ʸ���
	my $h = mysql_exec->select("               # �ʻ�ˤ��ե��륿
		SELECT name, khhinshi_id
		FROM   hselection
		WHERE  ifuse = 1
	",1)->hundle;
	while (my $i = $h->fetch){
		if (
			   $i->[0] =~ /B$/
			|| $i->[0] eq '�����ư��'
			|| $i->[0] eq '���ƻ����Ω��'
		){
			$filter->{hinshi}{$i->[1]} = 0;
		} else {
			$filter->{hinshi}{$i->[1]} = 1;
		}
	}
	
	return $self;
}

sub start{
	my $self = shift;
	$self->read_code;
	$self->clist_check;
}

#------------------------------------#
#   �롼��ե�����ι���������å�   #

sub activate{
	my $self = shift;
	return 1 unless $self->{codf_obj};
	return 1 unless -e $self->cfile;
	return 1 unless $self->{timestamp};
	
	unless ( ( stat($self->cfile) )[9] == $self->{timestamp} ){
		print "reload: ".$self->cfile."\n";
		my @selected = $self->{clist}->infoSelection;
		$self->read_code;
		$self->{clist}->selectionClear;
		foreach my $i (@selected){
			$self->{clist}->selectionSet($i)
				if $self->{clist}->info('exists', $i);
		}
		$self->clist_check;
	}
	return $self;
}

#----------------------------#
#   �롼��ե������ɤ߹���   #

sub read_code{
	my $self = shift;
	
	$self->{clist}->delete('all');
	
	# ��ľ�����ϡפ��ɲ�
	$self->{clist}->add(0,-at => 0);
	$self->{clist}->itemCreate(
		0,
		0,
		-text  => $self->gui_jchar('��ľ������'),
	);
	#$self->{clist}->selectionClear;
	$self->{clist}->selectionSet(0);

	# �롼��ե�������ɤ߹���
	unless (-e $self->cfile ){
		$self->{code_obj} = kh_cod::asso->new;
		return 0;
	}
	
	$self->{timestamp} = ( stat($self->cfile) )[9];
	my $cod_obj = kh_cod::asso->read_file($self->cfile);
	unless (eval(@{$cod_obj->codes})){
		$self->{code_obj} = kh_cod::asso->new;
		return 0;
	}
	
	my $row = 1;
	foreach my $i (@{$cod_obj->codes}){
		$self->{clist}->add($row,-at => "$row");
		$self->{clist}->itemCreate(
			$row,
			0,
			-text  => $self->gui_jchar($i->name),
		);
		++$row;
	}
	$self->{code_obj} = $cod_obj;
	
	# �֥�����̵���פ���Ϳ
	$self->{clist}->add($row,-at => "$row");
	$self->{clist}->itemCreate(
		$row,
		0,
		-text  => $self->gui_jchar('��������̵��'),
	);
	
	gui_hlist->update4scroll($self->{clist});
	
	$self->clist_check;
	return $self;
}

#----------------------------------#
#   ��ľ�����ϡפ�on/off�ڤ��ؤ�   #

sub clist_check{
	my $self = shift;
	my @s = $self->{clist}->info('selection');
	
	if ( @s && $s[0] eq '0' ){
		$self->{direct_w_l}->configure(-foreground => 'black');
		$self->{direct_w_o}->configure(-state => 'normal');
		$self->{direct_w_e}->configure(-state => 'normal');
		$self->{direct_w_e}->configure(-background => 'white');
		$self->{direct_w_e}->focus;
	} else {
		$self->{direct_w_l}->configure(-foreground => 'gray');
		$self->{direct_w_o}->configure(-state => 'disable');
		$self->{direct_w_e}->configure(-state => 'disable');
		$self->{direct_w_e}->configure(-background => 'gray');
	}
	
	my $n = @s;
	if (  $n >= 2) {
		$self->{opt_w_method1}->configure(-state => 'normal');
	} else {
		$self->{opt_w_method1}->configure(-state => 'disable');
	}
}


#--------------#
#   �����¹�   #
#--------------#

sub search{
	my $self = shift;
	$self->activate;
	
	# ����Υ����å�
	my @selected = $self->{clist}->info('selection');
	unless (@selected){
		my $win = $self->win_obj;
		gui_errormsg->open(
			type   => 'msg',
			msg    => '�����ɤ����򤵤�Ƥ��ޤ���',
			window => \$win,
		);
		return 0;
	}
	
	# ��٥���ѹ�
	$self->{hits_label}->configure(-text => $self->gui_jchar(' ʸ����� 0'));
	$self->{status_label}->configure(
		-foreground => 'red',
		-text => 'Searching...'
	);
	$self->{rlist}->delete('all');
	$self->win_obj->update;
	sleep (0.01);
	
	
	# ľ��������ʬ���ɤ߹���
	$self->{code_obj}->add_direct(
		mode => $self->gui_jg( $self->{opt_direct} ),
		raw  => $self->gui_jg( $self->{direct_w_e}->get ),
	);
	
	# �������å��θƤӽФ��ʸ����¹ԡ�
	my $query_ok = $self->{code_obj}->asso(
		selected => \@selected,
		tani     => $self->tani,
		method   => $self->{opt_method1},
	);
	
	$self->{status_label}->configure(
		-foreground => 'blue',
		-text => 'Ready.'
	);
	
	if ($query_ok){
		$self->{code_obj} = $query_ok;
		$self->display;
	}
	return $self;
}

#------------------------#
#   ������̤ν񤭽Ф�   #

sub display{
	my $self = shift;
	
	unless ( $self->{code_obj}          ) {return undef;}
	unless ( $self->{code_obj}->doc_num ) {return undef;}
	
	# HList�ι���
	$self->{rlist}->headerConfigure(5,-text,$order_name->{$self->{opt_order}});
	
	$self->{result} = $self->{code_obj}->fetch_results(
		order  => $self->{opt_order},
		filter => $filter,
	);

	my $numb_style = $self->{rlist}->ItemStyle(
		'text',
		-anchor => 'e',
		-background => 'white',
		-font => "TKFN"
	);

	$self->{rlist}->delete('all');
	if ($self->{result}){
		my $row = 0;
		foreach my $i (@{$self->{result}}){
			$self->{rlist}->add($row,-at => "$row");
			$self->{rlist}->itemCreate(           # ���
				$row,
				0,
				-text  => $row + 1,
				-style => $numb_style
			);
			$self->{rlist}->itemCreate(           # ñ��
				$row,
				1,
				-text  => $self->gui_jchar($i->[0]),
			);
			$self->{rlist}->itemCreate(           # �ʻ�
				$row,
				2,
				-text  => $self->gui_jchar($i->[1]),
			);
			$self->{rlist}->itemCreate(           # ����
				$row,
				3,
				-text  => " $i->[2]"." ("."$i->[3]".")",
				-style => $numb_style
			);
			$self->{rlist}->itemCreate(           # ����
				$row,
				4,
				-text  => " $i->[4]"." ("."$i->[5]".")",
				-style => $numb_style
			);
			#$self->{rlist}->itemCreate(           # ����դ���Ω
			#	$row,
			#	5,
			#	-text  => "$i->[5]",
			#	-style => $numb_style
			#);
			$self->{rlist}->itemCreate(           # Sort
				$row,
				5,
				-text  => " ".sprintf("%.4f",$i->[6]),
				-style => $numb_style
			);
			++$row;
		}
	} else {
		$self->{result} = [];
	}
	
	# ��٥�ι���
	my $num_total = $self->{code_obj}->doc_num;
	gui_hlist->update4scroll($self->{rlist});
	$self->{hits_label}->configure(-text => $self->gui_jchar(" ʸ����� $num_total"));

	return $self;
}

#----------------------------#
#   �����ͥåȥ��������   #

sub net_calc{
	my $self = shift;
	
	unless ( $self->{code_obj}          ) {return undef;}
	unless ( $self->{code_obj}->doc_num ) {return undef;}
	
	my $n = 0;
	while ($self->{rlist}->info('exists', $n)){
		++$n;
	}
	if ($n < 4){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ꥹ�ȥ��åפ���Ƥ����ο���5̤���Τ��ᡢ��������ߤ��ޤ���',
		);
		return undef;
	}
	
	
	my $wait_window = gui_wait->start;
	
	# �ͥåȥ������˻��Ѥ����δ��ܷ�ID�ꥹ��
	my @words = @{$self->{code_obj}{query_words}};
	
	my $r = $self->{code_obj}->fetch_results(
		order   => $self->{opt_order},
		filter  => $filter,
		for_net => 1,
	);

	foreach my $i (@{$r}){
		push @words, $i->[0];
	}

	# ��ʸ�� x ��и�ץǡ����μ��Ф�
	my $r_command = mysql_crossout::selected::r_com->new(
		tani  => $self->{code_obj}->{tani},
		words => \@words,
	)->run;

	# ��������ʸ�����������
	my $docs = $self->{code_obj}->fetch_Doc_IDs;
	$r_command .= "target_docs <- c(";
	foreach my $i (@{$docs}){
		$r_command .= "$i,";
	}
	chop $r_command;
	$r_command .= ")\n";

	$r_command .= "d <- d[target_docs,]\n";

	$r_command .= "d <- t(d)\n";

	# ������Υꥹ�ȡʶ�Ĵ�ѡ�
	my $qw_name = $self->{code_obj}->fetch_query_words_name;
	if ($qw_name){
		$r_command .= "target_words <- c(";
		foreach my $i ( @{$qw_name} ){
			$r_command .= "\"$i\",";
		}
		chop $r_command;
		$r_command .= ")\n";
	}

	# �ǥե�����ͤ�����
	$r_command .= "# END: DATA\n\n";
	use plotR::network;
	my $plotR = plotR::network->new(
		font_size           => $::config_obj->r_default_font_size / 100,
		plot_size           => 640,
		n_or_j              => "n",
		edges_num           => 60,
		edges_jac           => 0,
		use_freq_as_size    => 0,
		use_freq_as_fsize   => 0,
		smaller_nodes       => 0,
		use_weight_as_width => 0,
		r_command           => $r_command,
		plotwin_name        => 'selected_netgraph',
	);
	
	$wait_window->end(no_dialog => 1);

	if ($::main_gui->if_opened('w_selected_netgraph_plot')){
		$::main_gui->get('w_selected_netgraph_plot')->close;
	}

	return 0 unless $plotR;

	gui_window::r_plot::selected_netgraph->open(
		plots       => $plotR->{result_plots},
		msg         => $plotR->{result_info},
		msg_long    => $plotR->{result_info_long},
		no_geometry => 1,
	);

	$plotR = undef;



}

#----------------------------#
#   ���󥳡����󥹸ƤӽФ�   #

sub conc{
	use gui_window::word_conc;
	my $self = shift;

	# �ѿ�����
	my @selected = $self->{rlist}->infoSelection;
	unless(@selected){
		return;
	}
	my $selected = $selected[0];
	my ($query, $hinshi);
	$query = $self->gui_jchar($self->{result}->[$selected][0]);
	$hinshi = $self->gui_jchar($self->{result}->[$selected][1]);
	
	# ���󥳡����󥹤θƤӽФ�
	my $conc = gui_window::word_conc->open;
	$conc->entry->delete(0,'end');
	$conc->entry4->delete(0,'end');
	$conc->entry2->delete(0,'end');
	$conc->entry->insert('end',$query);
	$conc->entry4->insert('end',$hinshi);
	$conc->search;

}

#--------------#
#   ��������   #

sub last_words{
	my $self = shift;
	return $self->{last_words};
}

sub cfile{
	my $self = shift;
	$self->{codf_obj}->cfile;
}

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub win_name{
	return 'w_doc_ass';
}

1;