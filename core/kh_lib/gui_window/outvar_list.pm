package gui_window::outvar_list;
use base qw(gui_window);
use strict;
use Tk;

use gui_window::outvar_list::midashi;
use mysql_outvar;

# ��٥롦����ȥ꡼�˥Х���ɤ�����
# ���Ĥ���פ���ɤ߹��ߡפ�

my $headings = kh_msg->get('headings');

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $self->{win_obj};
	$wmw->title($self->gui_jt(kh_msg->get('win_title'))); # �����ѿ��ȸ��Ф�

	my $fra4 = $wmw->Frame();
	my $adj  = $wmw->Adjuster(-widget => $fra4, -side => 'left');
	my $fra5 = $wmw->Frame();

	$fra4->pack(-side => 'left', -fill => 'both', -expand => 1, -padx => 2);
	$adj->pack (-side => 'left', -fill => 'y', -padx => 2, -pady => 2);
	$fra5->pack(-side => 'left', -fill => 'both', -expand => 1, -padx => 2);

	#----------------#
	#   �ѿ��ꥹ��   #

	$fra4->Label(
		-text => kh_msg->get('vars'), # ���ѿ��ꥹ��
	)->pack(-anchor => 'nw');

	my $lis_vr = $fra4->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 2,
		-padx             => 2,
		-background       => 'white',
		-selectmode       => 'extended',
		-selectforeground   => $::config_obj->color_ListHL_fore,
		-selectbackground   => $::config_obj->color_ListHL_back,
		-selectborderwidth  => 0,
		-highlightthickness => 0,
		#-indicator => 0,
		#-command          => sub {$self->_open_var;},
		-browsecmd        => sub {$self->_delayed_open_var;},
		-height           => 10,
	)->pack(-fill =>'both',-expand => 1);

	$lis_vr->header('create',0,-text => kh_msg->get('h_unit')); # ʸ��ñ��
	$lis_vr->header('create',1,-text => kh_msg->get('h_name')); # �ѿ�̾

	my $fra4_bts = $fra4->Frame()->pack(-fill => 'x', -expand => 0);

	$fra4_bts->Button(
		-text => kh_msg->get('del'), # ���
		-font => "TKFN",
#		-width => 8,
		-borderwidth => '1',
		-command => sub{$self->_delete;}
	)->pack(-padx => 2, -pady => 2, -anchor => 'nw', -side => 'left', -fill => 'y');

	$fra4_bts->Button(
		-text => kh_msg->get('export'), # ����
		-font => "TKFN",
#		-width => 8,
		-borderwidth => '1',
		-command => sub{$self->_export;}
	)->pack(-padx => 2, -pady => 2, -anchor => 'nw', -side => 'left', -fill => 'y');

	my $mb1 = $fra4_bts->Menubutton(
		-text        => kh_msg->get('read'), # ���ɤ߹���
		-tearoff     => 'no',
		-relief      => 'raised',
		-indicator   => 'no',
		-font        => "TKFN",
		#-width       => $self->{width},
		-borderwidth => 1,
	)->pack(-padx => 2, -pady => 2, -side => 'right');

	$mb1->command(
		-command => sub {gui_window::outvar_read::csv->open;},
		-label   => kh_msg->get('csv'), # CSV�ե�����
	);

	$mb1->command(
		-command => sub {gui_window::outvar_read::tab->open;},
		-label   => kh_msg->get('tabdel'), # ���ֶ��ڤ�ե�����
	);

	#----------------#
	#   �ѿ��ξܺ�   #

	my $fra5lab = $fra5->Frame()->pack(-anchor => 'w');

	$fra5lab->Label(
		-text => kh_msg->get('values'), # ���ͤȥ�٥롧
	)->pack(-side => 'left');

	$self->{label_name} = $fra5lab->Label(
		-text       => '  ',
		-foreground => 'blue',
	)->pack(-side => 'left');

	my $lis = $fra5->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground   => $::config_obj->color_ListHL_fore,
		-selectbackground   => $::config_obj->color_ListHL_back,
		-selectborderwidth  => 0,
		-highlightthickness => 0,
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => kh_msg->get('h_value')); # ��
	$lis->header('create',1,-text => kh_msg->get('h_label')); # ��٥�
	$lis->header('create',2,-text => kh_msg->get('h_freq')); # �ٿ�

	$lis->bind("<Shift-Double-1>", sub{$self->v_words;});
	$lis->bind("<Double-1>",       sub{$self->v_docs ;});
	$lis->bind("<Key-Return>",     sub{$self->v_docs ;});

	$self->{list_val} = $lis;

	my $fra5_ets = $fra5->Frame()->pack(-fill => 'x');
	my $fra5_bts = $fra5->Frame()->pack(-fill => 'x');
	#my $fra5_btm = $fra5->Frame()->pack(-fill => 'x');

	$self->{btn_save} = $fra5_ets->Button(
		-text        => kh_msg->get('save'), # ��٥����¸
		-font        => "TKFN",
		-borderwidth => '1',
		-command     => sub {$self->_save;}
	)->pack(
		-padx => 2,
		-pady => 2,
		-fill => 'x',
		-side => 'left',
		-expand => 1,
	);

	my $btn_doc = $fra5_bts->Button(
		-text        => kh_msg->get('docs'), # ʸ�񸡺�
		-font        => "TKFN",
		-borderwidth => '1',
		-command     => sub {$self->v_docs;}
	)->pack(-padx => 2, -pady => 2, -side => 'left', -fill => 'y');

	my $mb = $fra5_bts->Menubutton(
		-text        => kh_msg->get('words'), # ����ħ��
		-tearoff     => 'no',
		-relief      => 'raised',
		-indicator   => 'no',
		-font        => "TKFN",
		#-width       => $self->{width},
		-borderwidth => 1,
		-height => 1,
	)->pack(-padx => 2, -pady => 2, -side => 'left');

	$mb->command(
		-command => sub {$self->v_words;},
		-label   => kh_msg->get('selected'), # ���򤷤���
	);

	$mb->command(
		-command => sub {$self->v_words_list('xls')},
		-label   => kh_msg->get('catalogue_xls'), # ������Excel������
	);

	$mb->command(
		-command => sub {$self->v_words_list('csv')},
		-label   => kh_msg->get('catalogue_csv'), # ������CSV������
	);

	$wmw->Balloon()->attach(
		$mb,
		-balloonmsg => kh_msg->get('help_words'), # ���򤷤��ͤ����ʸ�����ħŪ�ʸ��õ�����ޤ�\n[Shift + �ͤ���֥륯��å�]
		-font       => "TKFN"
	);


	$fra5_bts->Label(
		-text => kh_msg->get('unit') # ñ�̡�
	)->pack(-side => 'left');

	# ���ߡ����äƤ���...
	$self->{opt_tani_fra} = $fra5_bts; #->Frame()->pack(-side => 'left');
	$self->{opt_tani} = gui_widget::optmenu->open(
		parent  => $fra5_bts,
		pack    => {-side => 'left', -padx => 2, -pady => 2},
		options => [
			[kh_msg->gget('paragraph'), 'dan'], # ����
			[kh_msg->gget('sentence'),  'bun']
		],
		variable => \$self->{calc_tani},
	);


	$wmw->Balloon()->attach(
		$btn_doc,
		-balloonmsg => kh_msg->get('help_docs'), # ���򤷤��ͤ����ʸ��򸡺����ޤ�\n[�ͤ���֥륯��å�]
		-font       => "TKFN"
	);

	#MainLoop;
	
	$self->{list}    = $lis_vr;
	#$self->{win_obj} = $wmw;
	$self->_fill;
	return $self;
}

#----------------------------#
#   �ʹطϤΥե��󥯥����   #
#----------------------------#

sub _save{
	my $self = shift;

	unless ($self->{selected_var_obj}){
		$self->win_obj->messageBox(
			-message => kh_msg->get('error_sel_a_var'), # �ѿ������򤵤�Ƥ��ޤ���
			-icon    => 'info',
			-type    => 'Ok',
			-title   => 'KH Coder'
		);
		return 0;
	}

	# �ѹ����줿��٥����¸
	foreach my $i (keys %{$self->{label}}){
		if (
			$self->{label}{$i}
			eq
			Jcode->new( $self->gui_jg($self->{entry}{$i}->get), 'sjis' )->euc
		){
			#print "skip: ", $self->gui_jg($self->{entry}{$i}->get), "\n";
			next;
		}
		$self->{selected_var_obj}->label_save(
			$i,
			Jcode->new( $self->gui_jg($self->{entry}{$i}->get), 'sjis' )->euc,
		);
		$self->{label}{$i} = Jcode->new(
			$self->gui_jg($self->{entry}{$i}->get), 'sjis'
		)->euc;
		#print "saved: ", $self->gui_jg($self->{entry}{$i}->get), "\n";
	}
	return $self;
}


sub v_docs{
	my $self = shift;
	
	unless ($self->{selected_var_obj}){
		$self->_error_no_var;
		return 0;
	}
	
	# �����꡼����
	my @selected = $self->{list_val}->infoSelection;
	unless(@selected){
		$self->{list_val}->selectionSet(0);
		@selected = $self->{list_val}->infoSelection;
	}
	my $query = $self->{list_val}->itemCget($selected[0], 0, -text);
	$query = '<>'.$self->gui_jchar($self->{selected_var_obj}->{name}).'-->'.$query;

	$query =~ s/"/""/g;
	$query = '"'.$query.'"' if $query =~ / |"/;

	
	# ��⡼�ȥ�����ɥ������
	my $win;
	if ($::main_gui->if_opened('w_doc_search')){
		$win = $::main_gui->get('w_doc_search');
	} else {
		$win = gui_window::doc_search->open;
	}
	
	$win->{tani_obj}->{raw_opt} = $self->gui_jg( $self->{calc_tani} );
	$win->{tani_obj}->mb_refresh;
	
	$win->{clist}->selectionClear;
	$win->{clist}->selectionSet(0);
	$win->clist_check;
	
	$win->{direct_w_e}->delete(0,'end');
	$win->{direct_w_e}->insert('end',$query);
	$win->win_obj->focus;
	$win->search;
}

sub v_words{
	my $self = shift;
	
	unless ($self->{selected_var_obj}){
		$self->_error_no_var;
		return 0;
	}
	
	# �����꡼����
	my @selected = $self->{list_val}->infoSelection;
	unless(@selected){
		$self->{list_val}->selectionSet(0);
		@selected = $self->{list_val}->infoSelection;
	}
	my $query = $self->{list_val}->itemCget($selected[0], 0, -text);
	$query = '<>'.$self->gui_jchar($self->{selected_var_obj}->{name}).'-->'.$query;
	
	$query =~ s/"/""/g;
	$query = '"'.$query.'"' if $query =~ / |"/;
	
	# ��⡼�ȥ�����ɥ������
	my $win;
	if ($::main_gui->if_opened('w_doc_ass')){
		$win = $::main_gui->get('w_doc_ass');
	} else {
		$win = gui_window::word_ass->open;
	}
	
	$win->{tani_obj}->{raw_opt} = $self->gui_jg( $self->{calc_tani} );
	$win->{tani_obj}->mb_refresh;
	
	$win->{clist}->selectionClear;
	$win->{clist}->selectionSet(0);
	$win->clist_check;
	
	$win->{direct_w_e}->delete(0,'end');
	$win->{direct_w_e}->insert('end',$query);
	$win->win_obj->focus;
	$win->search;
}


sub v_words_list{
	my $self      = shift;
	my $file_type = shift;
	
	unless ($self->{selected_var_obj}){
		$self->_error_no_var;
		return 0;
	}
	
	#print "ok! 0\n";
	
	# ��٥���ѹ����Ƥ���¸���ơ������ѿ����֥������Ȥ������
	$self->_save;
	$self->{selected_var_obj} = mysql_outvar::a_var->new(
		$self->{selected_var_obj}->{name}
	);

	# �ͤΥꥹ��
	my $values;
	foreach my $i (@{$self->{selected_var_obj}->print_values}){
		if ( $i eq '.' || $i =~ /missing/i || $i eq '��»��' ){
			next;
		}
		push @{$values}, $i;
	}

	# ��⡼�ȥ�����ɥ��ν���
	my $win;
	if ($::main_gui->if_opened('w_doc_ass')){
		$win = $::main_gui->get('w_doc_ass');
	} else {
		$win = gui_window::word_ass->open;
	}

	my $d;
	# �ͤ��Ȥ���ħŪ�ʸ�����
	foreach my $i (@{$values}){
		# �����꡼����
		my $query = '<>'.$self->{selected_var_obj}->{name}.'-->'.$i;

		$query =~ s/"/""/g;
		$query = '"'.$query.'"' if $query =~ / |"/;

		$query = $self->gui_jchar($query,'euc');
		
		# ��⡼�ȥ�����ɥ������
		$win->{tani_obj}->{raw_opt} = $self->gui_jg( $self->{calc_tani} );
		$win->{tani_obj}->mb_refresh;
		
		$win->{clist}->selectionClear;
		$win->{clist}->selectionSet(0);
		$win->clist_check;
		
		$win->{direct_w_e}->delete(0,'end');
		$win->{direct_w_e}->insert('end',$query);
		$win->win_obj->focus;
		$win->search;
		
		# �ͤμ���
		my $n = 0;
		while ($win->{rlist}->info('exists', $n)){
			if ( $win->{rlist}->itemExists($n, 1) ){
				$d->{$i}[$n][0] = 
					Jcode->new(
						$self->gui_jg(
								$win->{rlist}->itemCget($n, 1, -text)
						),
						'sjis'
					)->euc
				;
			}
			if ( $win->{rlist}->itemExists($n, 5) ){
				$d->{$i}[$n][1] = 
					Jcode->new(
						$self->gui_jg(
							$win->{rlist}->itemCget($n, 5, -text)
						),
						'sjis'
					)->euc
				;
			}
			++$n;
			last if $n >= 10;
		}
	}
	
	$file_type = '_write_'.$file_type;
	$self->$file_type($values,$d);
}

sub _write_csv{
	my $self   = shift;
	my $values = shift;
	my $d      = shift;

	# �����Ѥ�����
	my $b_row_max = @{$values};
	$b_row_max /= 4;
	$b_row_max = int($b_row_max) + 1 if $b_row_max > int($b_row_max);
	
	my $t = '';
	for (my $b_row = 0; $b_row < $b_row_max; ++$b_row){
		my @c = ($b_row * 4, $b_row * 4 + 1, $b_row * 4 + 2, $b_row * 4 + 3);
		foreach my $i (@c){                                 # �إå�
			$t .= kh_csv->value_conv($values->[$i]).",,";
		}
		chop $t;
		$t .= "\n";
		for (my $n = 0; $n <= 10; ++$n){                    # ���
			foreach my $i (@c){
				$t .= kh_csv->value_conv($d->{$values->[$i]}[$n][0]).",";
				$t .= "$d->{$values->[$i]}[$n][1],";
			}
			chop $t;
			$t .= "\n";
		}
	}
	
	$t = Jcode->new($t,'euc')->sjis if $::config_obj->os eq 'win32';
	
	# �ե�����ؽ���
	my $f = $::project_obj->file_TempCSV;
	open (TEMPCSV,">$f") or
		gui_errormsg->open(
			type => 'file',
			file => $f
		)
	;
	print TEMPCSV $t;
	close(TEMPCSV);
	gui_OtherWin->open($f);
}

sub _write_xls{
	my $self   = shift;
	my $values = shift;
	my $d      = shift;

	use Spreadsheet::WriteExcel;
	use Unicode::String qw(utf8 utf16);

	my $f    = $::project_obj->file_TempExcel;
	my $workbook  = Spreadsheet::WriteExcel->new($f);
	my $worksheet = $workbook->add_worksheet(
		utf8( Jcode->new('������1')->utf8 )->utf16,
		1
	);
	$worksheet->hide_gridlines(1);

	my $font = '';
	if ($] > 5.008){
		$font = kh_msg->get('mspgoth'); # �ͣ� �Х����å�
	} else {
		$font = 'MS PGothic';
	}
	$workbook->{_formats}->[15]->set_properties(
		font       => $font,
		size       => 9,
		valign     => 'vcenter',
		align      => 'center',
	);
	my $format_n = $workbook->add_format(         # ����
		num_format => '.000',
		size       => 9,
		font       => $font,
		align      => 'right',
	);
	my $format_nl = $workbook->add_format(        # ���͡����˷���
		num_format => '.000',
		size       => 9,
		font       => $font,
		align      => 'right',
		bottom     => 1,
	);
	my $format_c = $workbook->add_format(         # ʸ����
		font       => $font,
		size       => 9,
		align      => 'left',
		num_format => '@'
	);
	my $format_cl = $workbook->add_format(        # ʸ���󡦲��˷���
		font       => $font,
		size       => 9,
		align      => 'left',
		bottom     => 1,
		num_format => '@'
	);
	my $format_l = $workbook->add_format(         # ��˷���
		font       => $font,
		size       => 9,
		top        => 1,
		align      => 'center',
	);

	my $big_row = 0;
	my $col     = 0;
	my $n       = 0;
	foreach my $i (@{$values}){
		my $row = $big_row * 11 + 1;
		
		# �إå�
		my $format_m = $workbook->add_format(
			font          => $font,
			size          => 9,
			bottom        => 1,
			top           => 1,
			#align         => 'center',
			center_across => 1,
			num_format    => '@'
		);
		$worksheet->write_unicode(
			$row,
			$col,
			utf8( Jcode->new($i,'euc')->utf8 )->utf16,
			$format_m
		);
		$worksheet->write_blank(
			$row,
			$col + 1,
			$format_m
		);
		
		if ($col - 1 > 0){
			$worksheet->set_column($col - 1,$col - 1, 1);
			$worksheet->write_blank($row, $col - 1, $format_l);
		}
		
		++$row;
		
		# �ǡ���
		my $row_cu = 0;
		foreach my $h (@{$d->{$i}}){
			if ($row_cu == 9 && $n + 5 > @{$values}){       # ���˷�������
				$worksheet->write_unicode(
					$row,
					$col,
					utf8( Jcode->new($h->[0],'euc')->utf8 )->utf16,
					$format_cl
				);
				$worksheet->write_number(
					$row,
					$col + 1,
					$h->[1],
					$format_nl
				);
			} else {                                        # ����̵��
				$worksheet->write_unicode(
					$row,
					$col,
					utf8( Jcode->new($h->[0],'euc')->utf8 )->utf16,
					$format_c
				);
				$worksheet->write_number(
					$row,
					$col + 1,
					$h->[1],
					$format_n
				);
			}
			++$row;
			++$row_cu;
		}
		
		# ����(1)
		if ( $col - 1 > 0 && $n + 5 > @{$values} ){
			$worksheet->write_blank(
				$row - 1,
				$col - 1,
				$format_cl
			);
		}
		
		# ����Ĵ��
		$col += 3;
		if ($col > 10){
			$col = 0;
			++$big_row;
		}
		++$n;
	}

	# ����(2)
	if ($col > 0 && $col - 1 < 9 && $big_row > 0){
		$col -= 1;
		while ($col <= 10){
			$worksheet->write_blank(
				$big_row * 11 + 11,
				$col,
				$format_cl
			);
			++$col;
		}
	}


	$workbook->close;
	gui_OtherWin->open($f);
}

sub _error_no_var{
	my $self = shift;

	$self->win_obj->messageBox(
		-message => kh_msg->get('error_sel_a_vv'), # �ѿ��ޤ��ϸ��Ф������򤷤Ƥ���������
		-icon    => 'info',
		-type    => 'Ok',
		-title   => 'KH Coder'
	);

}

#----------------------------#
#   �ѿ��ϤΥե��󥯥����   #
#----------------------------#

sub _fill{
	my $self = shift;

	my $n = 0;
	$self->{list}->delete('all');
	$self->{var_list} = undef;

	# ���Ф�
	foreach my $i ('h1','h2','h3','h4','h5'){
		if (
			mysql_exec->select(
				"select status from status where name = \'$i\'",1
			)->hundle->fetch->[0]
		){
			$self->{list}->add($n,-at => "$n");
			$self->{list}->itemCreate($n,0,-text => $i);
			$self->{list}->itemCreate(
				$n,
				1,
				-text => $headings.substr($i,1,1), # ���Ф�
			);
			push @{$self->{var_list}}, [$i, $headings.substr($i,1,1)];
			++$n;
		}
	}
	
	# �����ѿ�
	my $h = mysql_outvar->get_list;
	foreach my $i (@{$h}){
		if ($i->[0] eq 'dan'){$i->[0] = '����';}
		if ($i->[0] eq 'bun'){$i->[0] = 'ʸ';}
		$self->{list}->add($n,-at => "$n");
		$self->{list}->itemCreate($n,0,-text => $self->gui_jchar($i->[0]),);
		$self->{list}->itemCreate($n,1,-text => $self->gui_jchar($i->[1]),);
		++$n;
		# my $chk = Jcode->new($i->[1])->icode;
		# print "$chk, $i->[1]\n";
	}
	if( $self->{var_list} ){
		$self->{var_list} = [ @{$self->{var_list}}, @{$h} ];
	} else {
		$self->{var_list} = $h;
	}
	gui_hlist->update4scroll($self->{list});
	return $self;
}

sub _delete{
	my $self = shift;
	my %args = @_;
	
	# �����ǧ
	my @selection = $self->{list}->info('selection');
	unless (@selection){
		gui_errormsg->open(
			type => 'msg',
			msg  => kh_msg->get('error_sel_a_var'),
		);
		return 0;
	}
	
	# ���Ф��������äƤ��ʤ��������å���
	foreach my $i (@selection){
		if ($self->{var_list}[$i][1] =~ /^$headings[1-5]$/){
			$self->win_obj->messageBox(
				-message => kh_msg->get('error_hd1'), # ���ߤΤȤ������Υ��ޥ�ɤǸ��Ф��������뤳�ȤϤǤ��ޤ���\nʬ���оݥե������ľ�ܽ������Ƥ���������
				-icon    => 'info',
				-type    => 'Ok',
				-title   => 'KH Coder'
			);
			return 0;
		}
	}
	
	# �����˺������Τ���ǧ
	unless ( $args{no_conf} ){
		my $confirm = $self->{win_obj}->messageBox(
			-title   => 'KH Coder',
			-type    => 'OKCancel',
			#-default => 'OK',
			-icon    => 'question',
			-message => kh_msg->get('del_ok'), # ���򤵤�Ƥ����ѿ��������ޤ�����
		);
		unless ($confirm =~ /^OK$/i){
			return 0;
		}
	}
	
	# ���˾ܺ�Window�������Ƥ�����Ϥ��ä����Ĥ���
	#$::main_gui->get('w_outvar_detail')->close
	#	if $::main_gui->if_opened('w_outvar_detail');
	
	# ����¹�
	foreach my $i (@selection){
		mysql_outvar->delete(
			tani => $self->{var_list}[$i][0],
			name => $self->{var_list}[$i][1],
		);
	}
	$self->_fill;
	$self->_clear_values;
}

sub _export{
	my $self = shift;
	
	# �����ǧ
	my @selection = $self->{list}->info('selection');
	unless (@selection){
		gui_errormsg->open(
			type => 'msg',
			msg  => kh_msg->get('error_sel_a_var'),
		);
		return 0;
	}
	my @vars = (); my $last = '';
	foreach my $i (@selection){
		push @vars, $self->{var_list}[$i][1];
		
		$last = $self->{var_list}[$i][0] unless length($last);
		
		unless ($last eq $self->{var_list}[$i][0]){
			gui_errormsg->open(
				type => 'msg',
				msg  => kh_msg->get('error_units'), # ����ñ�̤ΰۤʤ��ѿ�������٤���¸���뤳�ȤϤǤ��ޤ���
			);
			return 0;
		}
		if ($self->{var_list}[$i][1] =~ /^$headings[1-5]$/){
			$self->win_obj->messageBox(
				-message => kh_msg->get('error_hd2'), # ���ߤΤȤ������Υ��ޥ�ɤǸ��Ф�����Ϥ��뤳�ȤϤǤ��ޤ���\n�֥ƥ����ȥե�������ѷ��ץ�˥塼�����Ѥ���������
				-icon    => 'info',
				-type    => 'Ok',
				-title   => 'KH Coder'
			);
			return 0;
		}
	}

	# ��¸��ե�����̾
	my @types = (
		['CSV Files',[qw/.csv/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.csv',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt(kh_msg->get('saving')), # �����ѿ���̾�����դ�����¸
		-initialdir       => $self->gui_jchar($::config_obj->cwd)
	);
	unless ($path){
		return 0;
	}
	$path = gui_window->gui_jg_filename_win98($path);
	$path = gui_window->gui_jg($path);
	$path = $::config_obj->os_path($path);

	mysql_outvar->save(
		path => $path,
		vars => \@vars,
	);

	return 1;
}

# ���ޤ�®���ڡ�����gui_widget::optmenu��destroy��Ԥ��ȥ��顼�ˤʤ롩�Τǡ�
# �����ԤäƤߤơ������Ѥ�äƤ��ʤ��ä����Τ߼¹Ԥ����x 3��

sub _delayed_open_var{
	my $self = shift;

	#$self->{list}->anchorClear;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	$self->win_obj->after(
		80,
		sub{ $self->_delay_chk1_open_var($current, $cn) }
	);
}

sub _delay_chk1_open_var{
	my $self   = shift;
	my $chk    = shift;
	my $chk_n  = shift;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	#print Jcode->new("1: $chk, $chk_n, $current, $cn\n")->sjis ;
	
	if ($chk eq $current && $chk_n == $cn){
		$self->win_obj->after(
			120,
			sub{ $self->_delay_chk2_open_var($current, $cn) }
		);
	}
}

sub _delay_chk2_open_var{
	my $self   = shift;
	my $chk    = shift;
	my $chk_n  = shift;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	#print Jcode->new("2: $chk, $chk_n, $current, $cn\n")->sjis ;

	if ($chk eq $current && $chk_n == $cn){
		$self->win_obj->after(
			50,
			sub{ $self->_delay_chk3_open_var($current, $cn) }
		);
	}
}

sub _delay_chk3_open_var{
	my $self   = shift;
	my $chk    = shift;
	my $chk_n  = shift;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	#print Jcode->new("2: $chk, $chk_n, $current, $cn\n")->sjis ;

	if ($chk eq $current && $chk_n == $cn){
		my $class = 'gui_window::outvar_list';
		if ($self->{var_list}[$selection[0]][1] =~ /^$headings[1-5]$/){
			$class .= '::midashi';
		}
		bless $self, $class;

		$self->_open_var;
	}
}

sub _open_var{
	my $self = shift;
	
	my @selection = $self->{list}->info('selection');
	unless (@selection){
		return 0;
	}
	return 1 if
		   $self->{selected_var_obj}->{name}
		eq $self->{var_list}[$selection[0]][1];

	#print "go!\n";

	# �ѿ�̾��ɽ��
	$self->{label_name}->configure(
		-text => $self->gui_jchar(
			$self->{var_list}[$selection[0]][1]
		)
	);

	# �ͤȥ�٥��ɽ��
	$self->{label} = undef;
	$self->{list_val}->delete('all');
	$self->{selected_var_obj} = mysql_outvar::a_var->new($self->{var_list}[$selection[0]][1]);
	my $v = $self->{selected_var_obj}->detail_tab;
	my $n = 0;
	my $right = $self->{list_val}->ItemStyle('text',
		-anchor           => 'e',
		-background       => 'white',
		-selectbackground => 'white',
		-activebackground => 'white',
	);
	my $left = $self->{list_val}->ItemStyle('text',
		-anchor           => 'w',
		-background       => 'white',
		-selectbackground => 'white',
		-activebackground => 'white',
	);
	foreach my $i (@{$v}){
		$self->{list_val}->add($n,-at => "$n");
		$self->{list_val}->itemCreate(
			$n,
			0,
			-text  => $self->gui_jchar($i->[0]),
			-style => $left
		);
		$self->{list_val}->itemCreate(
			$n,
			2,
			-text  => $self->gui_jchar($i->[2]),
			-style => $right
		);
		
		my $c = $self->{list_val}->Entry(
			-font  => "TKFN",
			-width => 15
		);
		$self->{list_val}->itemCreate(
			$n,1,
			-itemtype  => 'window',
			-widget    => $c,
		);
		$c->insert(0,$self->gui_jchar($i->[1]));
		#$c->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$c]);
		$c->bind(
			"<Key-Return>",
			sub{
				$self->{btn_save}->focus;
				#$self->{btn_save}->invoke;
			}
		);
		
		$self->{entry}{$i->[0]} = $c;
		$self->{label}{$i->[0]} = $i->[1];
		++$n;
	}
	gui_hlist->update4scroll($self->{list_val});

	#$self->{label_num}->configure(
	#	-text => $self->gui_jchar("�ͤμ��ࡧ $n")
	#);

	# ����ñ��
	my @tanis   = ();
	if ($self->{opt_tani}){
		$self->{opt_tani}->destroy;
		$self->{opt_tani} = undef;
	}

	my %tani_name = (
		"bun" => kh_msg->gget('sentence'),# "ʸ",
		"dan" => kh_msg->gget('paragraph'),# "����",
		"h5"  => "H5",
		"h4"  => "H4",
		"h3"  => "H3",
		"h2"  => "H2",
		"h1"  => "H1",
	);

	@tanis = ();
	my $flag_t = 0;
	foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
		$flag_t = 1 if ($self->{selected_var_obj}->tani eq $i);
		if (
			   $flag_t
			&& mysql_exec->select(
				   "select status from status where name = \'$i\'",1
			   )->hundle->fetch->[0]
		){
			push @tanis, [$self->gui_jchar($tani_name{$i}),$i];
		}
	}

	if (@tanis){
		$self->{opt_tani} = gui_widget::optmenu->open(
			parent  => $self->{opt_tani_fra},
			pack    => {-side => 'left', -padx => 2},
			options => \@tanis,
			variable => \$self->{calc_tani},
		);
	}

	$self->{btn_save}->configure(-state => 'normal');

	#gui_window::outvar_detail->open(
	#	tani => $self->{var_list}[$selection[0]][0],
	#	name => $self->{var_list}[$selection[0]][1],
	#);
}

sub _clear_values{
	my $self = shift;
	
	$self->{selected_var_obj} = undef;
	$self->{label} = undef;
	
	$self->{label_name}->configure(
		-text => '  '
	);
		
	$self->{list_val}->delete('all');
	
	$self->{opt_tani}->destroy;
	$self->{opt_tani} = undef;
	
	return 1;
}

#--------------#
#   ��������   #
#--------------#


sub win_name{
	return 'w_outvar_list';
}


1;
