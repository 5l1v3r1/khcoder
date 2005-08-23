package gui_window::word_conc;
use base qw(gui_window);
use strict;
use Tk;
use Tk::HList;
#use NKF;
use mysql_conc;
use Jcode;
use gui_widget::tani;
use gui_widget::optmenu;

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $mw->Toplevel;
	#$wmw->focus;
	$wmw->title($self->gui_jchar('���󥳡����� ��KWIC��'));

	my $fra4 = $wmw->LabFrame(
		-label => 'Search Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'x');

	# ����ȥ�ȸ����ܥ���Υե졼��
	my $fra4e = $fra4->Frame()->pack(-expand => 'y', -fill => 'x');

	$fra4e->Label(
		-text => $self->gui_jchar('��и졧'),
		-font => "TKFN"
	)->pack(-side => 'left');

	my $e1 = $fra4e->Entry(
		-font => "TKFN",
		-background => 'white',
		-width => 14
	)->pack(-side => 'left');
	$wmw->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);
	$e1->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$e1]);
	$e1->bind("<Key-Return>",sub{$self->search;});

	$fra4e->Label(
		-text => $self->gui_jchar('���ʻ졧'),
		-font => "TKFN"
	)->pack(-side => 'left');

	my $e4 = $fra4e->Entry(
		-font => "TKFN",
		-background => 'white',
		-width => 8
	)->pack(-side => 'left');
	$e4->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$e4]);
	$e4->bind("<Key-Return>",sub{$self->search;});

	$fra4e->Label(
		-text => $self->gui_jchar('�����ѷ���'),
		-font => "TKFN"
	)->pack(-side => 'left');

	my $e2 = $fra4e->Entry(
		-font => "TKFN",
		-width => 8,
		-background => 'white'
	)->pack(-side => 'left');
	$e2->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$e2]);
	$e2->bind("<Key-Return>",sub{$self->search;});

	$fra4e->Label(
		-text => $self->gui_jchar('����'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{btn_tuika} = $fra4e->Button(
		-text => $self->gui_jchar('�ʤ����'),
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'left');

	my $sbutton = $fra4e->Button(
		-text => $self->gui_jchar('����'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->search;});} 
	)->pack(-side => 'right', -padx => '2');

	my $blhelp = $wmw->Balloon();
	$blhelp->attach(
		$sbutton,
		-balloonmsg => '"ENTER" key',
		-font => "TKFN"
	);

	# �����ȡ����ץ����Υե졼��
	my $fra4h = $fra4->Frame->pack(-expand => 'y', -fill => 'x', -pady => 2);

	my @options = (
		[ $self->gui_jchar('�и���'), 'id'],
		[ $self->gui_jchar('����5'),  'l5'],
		[ $self->gui_jchar('����4'),  'l4'],
		[ $self->gui_jchar('����3'),  'l3'],
		[ $self->gui_jchar('����2'),  'l2'],
		[ $self->gui_jchar('����1'),  'l1'],
		[ $self->gui_jchar('���ѷ�'), 'center'],
		[ $self->gui_jchar('����1'),  'r1'],
		[ $self->gui_jchar('����2'),  'r2'],
		[ $self->gui_jchar('����3'),  'r3'],
		[ $self->gui_jchar('����4'),  'r4'],
		[ $self->gui_jchar('����5'),  'r5']
	);

	$fra4h->Label(
		-text => $self->gui_jchar('������1��'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{menu1} = gui_widget::optmenu->open(
		parent   => $fra4h,
		pack     => {-anchor=>'e', -side => 'left'},
		options  => \@options,
		variable => \$self->{sort1},
		width    => 6,
		command  => sub{ $mw->after(10,sub{$self->_menu_check;});} 
	);

	$fra4h->Label(
		-text => $self->gui_jchar('��������2��'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{menu2} = gui_widget::optmenu->open(
		parent   => $fra4h,
		pack     => {-anchor=>'e', -side => 'left'},
		options  => \@options,
		variable => \$self->{sort2},
		width    => 6,
		command  => sub{ $mw->after(10,sub{$self->_menu_check;});} 
	);

	$fra4h->Label(
		-text => $self->gui_jchar('��������3��'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{menu3} = gui_widget::optmenu->open(
		parent   => $fra4h,
		pack     => {-anchor=>'e', -side => 'left'},
		options  => \@options,
		variable => \$self->{sort3},
		width    => 6,
		command  => sub{ $mw->after(10,sub{$self->_menu_check;});} 
	);
	$self->_menu_check;


	$fra4h->Label(
		-text => $self->gui_jchar('��������'),
		-font => "TKFN"
	)->pack(-side => 'left');

	my $e3 = $fra4h->Entry(
		-width => 2,
		-background => 'white'
	)->pack(-side => 'left');
	$e3->insert('end','20');

	$fra4h->Label(
		-text => $self->gui_jchar('���ɽ����'),
		-font => "TKFN"
	)->pack(-side => 'left');


	my $status = $fra4h->Label(
		-text => 'Ready.',
		-foreground => 'blue'
	)->pack(-side => 'right');

	# ���ɽ����ʬ
	my $fra5 = $wmw->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2
	)->pack(-expand=>'yes',-fill=>'both');

	my $hlist_fra = $fra5->Frame()->pack(-expand => 'y', -fill => 'both');

	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 0,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'black',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-height           => 20,
		-command          => sub {$mw->after(10,sub{$self->view_doc;});}
	)->pack(-fill =>'both',-expand => 'yes');

	$fra5->Button(
		-text => $self->gui_jchar('���ԡ�'),
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'left',-anchor => 'w', -pady => 1, -padx => 2);

	$fra5->Button(
		-text => $self->gui_jchar('ʸ��ɽ��'),
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {$self->view_doc;});} 
	)->pack(-side => 'left',-anchor => 'w', -pady => 1);

	$fra5->Label(
		-text => $self->gui_jchar(' ɽ��ñ�̡�'),
		-font => "TKFN"
	)->pack(-side => 'left');
	
	my %pack = (
		-side => 'left',
		-pady => 1
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $fra5,
		pack   => \%pack
	);

	$fra5->Label(
		-text => '  ',
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{btn_prev} = $fra5->Button(
		-text        => $self->gui_jchar('��'.mysql_conc->docs_per_once,'euc'),
		-font        => "TKFN",
		-command     =>
			sub{
				my $start =
					$self->{current_start} - mysql_conc->docs_per_once;
				$self->display($start);
			},
		-borderwidth => 1,
		-state       => 'disable',
	)->pack(-side => 'left',-padx => 2);

	$self->{btn_next} = $fra5->Button(
		-text        => $self->gui_jchar('��'.mysql_conc->docs_per_once,'euc'),
		-font        => "TKFN",
		-command     =>
			sub{
				my $start =
					$self->{current_start} + mysql_conc->docs_per_once;
				$self->display($start);
			},
		-borderwidth => 1,
		-state       => 'disable',
	)->pack(-side => 'left');

	my $hits = $fra5->Label(
		-text => $self->gui_jchar('  �ҥåȿ���'),
		-font => "TKFN"
	)->pack(-side => 'left');

	$self->{btn_coloc} = $fra5->Button(
		-text        => $self->gui_jchar('����','euc'),
		-font        => "TKFN",
		-command     => sub{ $mw->after(10,sub{$self->coloc;});},
		-borderwidth => 1,
		-state       => 'disable'
	)->pack(-side => 'right');


	MainLoop;

	# $self->{entry_limit} = $limit_e;
	$self->{st_label} = $status;
	$self->{hit_label} = $hits;
	$self->{list}     = $lis;
	$self->{win_obj}  = $wmw;
	$self->{entry}    = $e1;
	$self->{entry2}    = $e2;
	$self->{entry3}    = $e3;
	$self->{entry4}    = $e4;
	return $self;
}

#------------------------#
#   ��˥塼�ξ����ѹ�   #
#------------------------#
sub _menu_check{
	my $self = shift;
	my $flag = 0;
	for (my $n = 1; $n <= 3; ++$n){
		if ($flag){
			$self->menu($n)->configure(-state, 'disable');
		} else {
			$self->menu($n)->configure(-state, 'normal');
		}
		
		if ($self->sort($n) eq 'id'){
			$flag = 1;
		}
	}
}

#--------------#
#   ʸ��ɽ��   #
#--------------#
sub view_doc{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return;
	}
	my $selected = $selected[0];
	my $tani = $self->doc_view_tani;
	my @kyotyo = @{mysql_conc->last_words};
	my $hyosobun_id = $self->result->[$selected][3];

	$selected = $self->{current_start} + $selected;
	my $foot = $self->{result_obj}->_count;
	$foot = "������ɽ�����ʸ�� $selected / "."$foot";
	$foot = Jcode->new($foot)->sjis;

	my $view_win = gui_window::doc_view->open;
	$view_win->view(
		hyosobun_id => $hyosobun_id,
		kyotyo      => \@kyotyo,
		tani        => "$tani",
		parent      => $self,
		foot        => $foot,
	);
}

sub next{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return -1;
	}
	my $selected = $selected[0] + 1;
	my $max = @{$self->result} - 1;
	if ($selected > $max){
		$selected = $max;
	}
	my $hyosobun_id = $self->result->[$selected][3];
	
	$self->list->selectionClear;
	$self->list->selectionSet($selected);
	$self->list->yview($selected);
	my $n = @{$self->result};
	if ($n - $selected > 7){
		$self->list->yview(scroll => -5, 'units');
	}
	
	$selected = $self->{current_start} + $selected;
	my $foot = $self->{result_obj}->_count;
	$foot = "������ɽ�����ʸ�� $selected / "."$foot";
	$foot = Jcode->new($foot)->sjis;

	return ($hyosobun_id,undef,$foot);
}

sub prev{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return -1;
	}
	my $selected = $selected[0] - 1;
	if ($selected < 0){
		$selected = 0;
	}
	my $hyosobun_id = $self->result->[$selected][3];
	
	$self->list->selectionClear;
	$self->list->selectionSet($selected);
	$self->list->yview($selected);
	my $n = @{$self->result};
	if ($n - $selected > 7){
		$self->list->yview(scroll => -5, 'units');
	}
	
	$selected = $self->{current_start} + $selected;
	my $foot = $self->{result_obj}->_count;
	$foot = "������ɽ�����ʸ�� $selected / "."$foot";
	$foot = Jcode->new($foot)->sjis;

	return ($hyosobun_id,undef,$foot);
}

sub if_next{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return 0;
	}
	my $selected = $selected[0] ;
	my $max = @{$self->result} - 1;
	if ($selected < $max){
		return 1;
	} else {
		return 0;
	}
}
sub if_prev{
	my $self = shift;
	my @selected = $self->list->infoSelection;
	unless (@selected){
		return 0;
	}
	my $selected = $selected[0] ;
	if ($selected > 0){
		return 1;
	} else {
		return 0;
	}
}
sub end{
	if ($::main_gui){
		$::main_gui->get('w_doc_view')->close
			if $::main_gui->if_opened('w_doc_view');
		$::main_gui->get('w_word_conc_coloc')->close
			if $::main_gui->if_opened('w_word_conc_coloc');
	}
}

#----------#
#   ����   #
#----------#

sub coloc{
	my $self = shift;
	$self->{result_obj}->coloc;
	
	my $view_win = gui_window::word_conc_coloc->open;
	$view_win->view($self->{result_obj});
}


#----------#
#   ����   #
#----------#

sub search{
	my $self = shift;

	# �ѿ�����
	my $query = Jcode->new($self->gui_jg($self->entry->get))->euc;
	unless ($query){
		return;
	}
	my $katuyo = Jcode->new($self->gui_jg($self->entry2->get))->euc;
	my $hinshi = Jcode->new($self->gui_jg($self->entry4->get))->euc;
	my $length = $self->entry3->get;

	# ɽ���ν����
	$self->hit_label->configure(
		-text => $self->gui_jchar("  �ҥåȿ���")
	);
	$self->list->delete('all');
	$self->{btn_prev}->configure(-state => 'disable');
	$self->{btn_next}->configure(-state => 'disable');
	$self->{btn_coloc}->configure(-state => 'disable');
	$self->st_label->configure(
		-text => 'Searching...',
		-foreground => 'red',
	);
	$self->win_obj->update;

	# �����¹�
	use Benchmark;
	my $t0 = new Benchmark;

	# my ($result, $r_num)
	$self->{result_obj} = mysql_conc->a_word(
		query  => $query,
		katuyo => $katuyo,
		hinshi => $hinshi,
		length => $length,
		sort1  => $self->sort1,
		sort2  => $self->sort2,
		sort3  => $self->sort3,
	);

	$self->st_label->configure(
		-text => 'Ready.',
		-foreground => 'blue',
	);

	$self->display(1);
	
	if (
		   defined( $::main_gui->{'w_word_conc_coloc'})
		&& Exists($::main_gui->{'w_word_conc_coloc'}->win_obj)
	){
		$self->{result_obj}->coloc if $self->{result_obj};
		$::main_gui->get('w_word_conc_coloc')->view($self->{result_obj});
	}
	
	my $t1 = new Benchmark;
	print timestr(timediff($t1,$t0)),"\n";
	
	return $self;
}

#--------------#
#   ���ɽ��   #
#--------------#

sub display{
	my $self = shift;
	my $start = shift;
	
	$self->{current_start} = $start;
	
	# HList�ι���
	unless ($self->{result_obj}){
		return undef;
	}
	my $result = $self->{result_obj}->_format($start);
	$self->list->delete('all');
	unless ($result){
		$self->st_label->configure(
			-text => 'Ready.',
			-foreground => 'blue',
		);
		$self->win_obj->update;
		return 0;
	}
	
	my $right_style = $self->list->ItemStyle(
		'text',
		-font => "TKFN",
		-anchor => 'e',
		-background => 'white'
	);
	my $center_style = $self->list->ItemStyle(
		'text',
		-anchor => 'c',
		-font => "TKFN",
		-background => 'white',
		-foreground => 'red'
	);

	my $row = 0;
	foreach my $i (@{$result}){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate(
			$row,
			0,
			-text  => $self->gui_jchar($i->[0],'euc'), #nkf('-s -E',$i->[0]),
			-style => $right_style
		);
		my $center = $self->list->itemCreate(
			$row,
			1,
			-text  => $self->gui_jchar($i->[1],'euc'), #nkf('-s -E',$i->[1]),
			-style => $center_style
		);
		$self->list->itemCreate(
			$row,
			2,
			-text  => $self->gui_jchar($i->[2],'euc'), #nkf('-s -E',$i->[2])
		);
		++$row;
	}

	# ��٥�ι���
	my $num_total = $self->{result_obj}->_count;
	my $num_disp  = $start + mysql_conc->docs_per_once - 1;
	my $num_disp2;
	if ($num_total > $num_disp){
		$num_disp2 = $num_disp;
	} else {
		$num_disp2 = $num_total;
	}
	if ($num_total == 0){$start = 0;}
	$self->hit_label->configure(-text => $self->gui_jchar("  �ҥåȿ��� $num_total  ɽ���� $start"."-$num_disp2"));
	
	# �ܥ���ι���
	if ($start > 1){
		$self->{btn_prev}->configure(-state => 'normal');
	} else {
		$self->{btn_prev}->configure(-state => 'disable');
	}
	if ($num_total > $num_disp){
		$self->{btn_next}->configure(-state => 'normal');
	} else {
		$self->{btn_next}->configure(-state => 'disable');
	}
	$self->{btn_coloc}->configure(-state => 'normal');
	$self->win_obj->update;

	# ɽ���Υ��󥿥��
	$self->list->xview(moveto => 1);
	$self->list->yview(0);
	$self->win_obj->update;

	my $w_col0 = $self->list->columnWidth(0);
	my $w_col1 = $self->list->columnWidth(1);
	my $w_col2 = $self->list->columnWidth(2);

	my $xv;
	if ($Tk::version >= 8.4){
		$xv = $self->list->xview->[0];
	} else {
		$xv = $self->list->xview;
	}

	my $visible = ($w_col0 + $w_col1 + $w_col2 - $xv);
	my $v_center = int( $visible / 2);
	#print "$v_center\n";
	my $s_center = $w_col0 + ( $w_col1 / 2 );
	my $s_scroll = $s_center - $v_center;
	#print "s_scroll: $s_scroll\n";
	if ($s_scroll < 0){
		$self->list->xview(moveto => 0);
	} else {
		my $fragment = $s_scroll / ($w_col0 + $w_col1 + $w_col2);
		#print "fragment: $fragment\n";
		$self->list->xview(moveto => $fragment);
	}
	$self->list->yview(0);
	
	$self->{result} = $result;
	return $self;
}

#------------#
#   �����   #
#------------#

sub start{
	my $self = shift;
	mysql_conc->initialize;
	$self->entry->focus;
}


#--------------#
#   ��������   #
#--------------#

sub result{
	my $self = shift;
	return $self->{result};
}
sub list{
	my $self = shift;
	return $self->{list};
}
sub entry{
	my $self = shift;
	return $self->{entry};
}
sub entry2{
	my $self = shift;
	return $self->{entry2};
}
sub entry3{
	my $self = shift;
	return $self->{entry3};
}
sub entry4{
	my $self = shift;
	return $self->{entry4};
}
sub st_label{
	my $self= shift;
	return $self->{st_label};
}
sub hit_label{
	my $self= shift;
	return $self->{hit_label};
}
sub sort1{ my $self = shift; return $self->{sort1};}
sub sort2{ my $self = shift; return $self->{sort2};}
sub sort3{ my $self = shift; return $self->{sort3};}
sub sort{  my $self = shift; return $self->{"sort$_[0]"};}
sub doc_view_tani{ my $self = shift; return $self->{tani_obj}->tani;}
sub menu{
	my $self = shift;
	my $key = "menu"."$_[0]";
	return $self->{"$key"};
}
sub win_name{
	return 'w_word_conc';
}

1;
