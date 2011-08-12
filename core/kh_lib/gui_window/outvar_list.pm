package gui_window::outvar_list;
use base qw(gui_window);
use strict;
use Tk;

use mysql_outvar;

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $self->{win_obj};
	$wmw->title($self->gui_jt('�����ѿ��ꥹ��'));

	#----------------#
	#   �ѿ��ꥹ��   #

	my $fra4 = $wmw->Frame();
	my $adj  = $wmw->Adjuster(-widget => $fra4, -side => 'left');
	my $fra5 = $wmw->Frame();

	$fra4->pack(-side => 'left', -fill => 'both', -expand => 1, -padx => 2);
	$adj->pack (-side => 'left', -fill => 'y', -padx => 2);
	$fra5->pack(-side => 'left', -fill => 'both', -expand => 1, -padx => 2);

	$fra4->Label(
		-text => $self->gui_jchar('���ѿ��ꥹ��'),
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
		#-selectforeground => 'brown',
		-selectbackground => '#AFEEEE',
		-selectborderwidth=> 0,
		-selectmode       => 'extended',
		#-selectborderwidth => 0,
		#-indicator => 0,
		-highlightthickness => 0,
		#-command          => sub {$self->_open_var;},
		-browsecmd        => sub {$self->_delayed_open_var;},
		-height           => 10,
	)->pack(-fill =>'both',-expand => 1);

	$lis_vr->header('create',0,-text => $self->gui_jchar('ʸ��ñ��'));
	$lis_vr->header('create',1,-text => $self->gui_jchar('�ѿ�̾'));

	my $fra4_bts = $fra4->Frame()->pack(-fill => 'x', -expand => 0);

	#$fra4_bts->Button(
	#	-text => $self->gui_jchar('�ܺ�'),
	#	-font => "TKFN",
#	#	-width => 8,
	#	-command => sub{$self->_open_var;}
	#)->pack(-anchor => 'ne', -side => 'right');

	$fra4_bts->Button(
		-text => $self->gui_jchar('���'),
		-font => "TKFN",
#		-width => 8,
		-borderwidth => '1',
		-command => sub{$self->_delete;}
	)->pack(-padx => 2, -pady => 2, -anchor => 'nw', -side => 'left');

	$fra4_bts->Button(
		-text => $self->gui_jchar('����'),
		-font => "TKFN",
#		-width => 8,
		-borderwidth => '1',
		-command => sub{$self->_export;}
	)->pack(-padx => 2, -pady => 2, -anchor => 'nw', -side => 'left');

	$fra4_bts->Button(
		-text => $self->gui_jchar('�Ĥ���'),
		-font => "TKFN",
#		-width => 8,
		-borderwidth => '1',
		-command => sub{$self->close;}
	)->pack(-padx => 2, -pady => 2, -anchor => 'ne', -side => 'right');

	#----------------#
	#   �ѿ��ξܺ�   #

	$self->{label_name} = $fra5->Label(
		-text => $self->gui_jchar('���ѿ��ξܺ�'),
	)->pack(-anchor => 'nw');

	my $lis = $fra5->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'black',
		-selectbackground => '#F0E68C',
		-selectmode       => 'single',
		-selectborderwidth=> 0,
		-highlightthickness => 0,
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => $self->gui_jchar('��'));
	$lis->header('create',1,-text => $self->gui_jchar('��٥�'));
	$lis->header('create',2,-text => $self->gui_jchar('�ٿ�'));

	$lis->bind("<Shift-Double-1>", sub{$self->v_words;});
	$lis->bind("<Double-1>",       sub{$self->v_docs ;});
	$lis->bind("<Key-Return>",     sub{$self->v_docs ;});

	$self->{list_val} = $lis;

	#my $fra5_ets = $fra5->Frame()->pack(-fill => 'x', -expand => 0);
	my $fra5_bts = $fra5->Frame()->pack(-fill => 'x', -expand => 0);
	$self->{opt_tani_fra} = $fra5_bts;

	#$fra5_ets->Label(
	#	-text => $self->gui_jchar('�ѿ�̾��ñ�̡ˡ�')
	#)->pack(-side => 'left');
	#
	#$self->{entry_name} = $fra5_ets->Entry(
	#	-state => 'disabled',
	#	-disabledbackground => 'gray',
	#	-background => 'gray',
	#	-disabledforeground => 'black',
	#)->pack(-side => 'left', -fill => 'x', -expand => 1);

	$fra5_bts->Button(
		-text        => $self->gui_jchar('��٥���ѹ�����¸'),
		-font        => "TKFN",
		-borderwidth => '1',
		-command     => sub {$self->v_docs;}
	)->pack(-padx => 2, -pady => 2, -anchor => 'e');

	my $btn_doc = $fra5_bts->Button(
		-text        => $self->gui_jchar('ʸ�񸡺�'),
		-font        => "TKFN",
		-borderwidth => '1',
		-command     => sub {$self->v_docs;}
	)->pack(-padx => 2, -pady => 2, -side => 'left');

	$wmw->Balloon()->attach(
		$btn_doc,
		-balloonmsg => $self->gui_jchar('������ͤ����ʸ��򸡺����ޤ�'),
		-font       => "TKFN"
	);

	#my $btn_aso = $fra5_bts->Button(
	#	-text        => $self->gui_jchar('��ħ��'),
	#	-font        => "TKFN",
	#	-borderwidth => '1',
	#	-command     => sub {$self->v_words;}
	#)->pack(-padx => 2, -pady => 2, -side => 'left');
	#
	#$wmw->Balloon()->attach(
	#	$btn_aso,
	#	-balloonmsg => $self->gui_jchar('������ͤ����ʸ��򸡺�����������ʸ�����ħŪ�ʸ��õ�����ޤ�'),
	#	-font       => "TKFN"
	#);

	my $mb = $fra5_bts->Menubutton(
		-text        => $self->gui_jchar('��ħ��'),
		-tearoff     => 'no',
		-relief      => 'raised',
		-indicator   => 'no',
		-font        => "TKFN",
		#-width       => $self->{width},
		-borderwidth => 1,
	)->pack(-padx => 2, -pady => 2, -side => 'left');

	$mb->command(
		-command => sub {$self->v_words;},
		-label   => $self->gui_jchar('���򤷤��ͤΤ�'),
	);

	$mb->command(
		-command => sub {$self->v_words_list('xls')},
		-label   => $self->gui_jchar('������Excel������'),
	);

	$mb->command(
		-command => sub {$self->v_words_list('csv')},
		-label   => $self->gui_jchar('������CSV������'),
	);

	$wmw->Balloon()->attach(
		$mb,
		-balloonmsg => $self->gui_jchar('������ͤ����ʸ�����ħŪ�ʸ��õ�����ޤ�'),
		-font       => "TKFN"
	);

	$fra5_bts->Label(
		-text => $self->gui_jchar('����ñ�̡�')
	)->pack(-side => 'left');

	# ���ߡ�
	$self->{opt_tani} = gui_widget::optmenu->open(
		parent  => $self->{opt_tani_fra},
		pack    => {-side => 'left', -padx => 2},
		options => [
			[$self->gui_jchar('����'), 'dan'],
			[$self->gui_jchar('ʸ'  ), 'bun']
		],
		variable => \$self->{calc_tani},
	);

	#$fra4_bts->Button(
	#	-text => $self->gui_jchar('�Ĥ���'),
	#	-font => "TKFN",
	#	-width => 8,
	#	-command => sub{$self->close;}
	#)->pack(-side => 'right',-padx => 2);

	#MainLoop;
	
	$self->{list}    = $lis_vr;
	#$self->{win_obj} = $wmw;
	$self->_fill;
	return $self;
}

#--------------------#
#   �ե��󥯥����   #
#--------------------#

sub _fill{
	my $self = shift;
	
	my $h = mysql_outvar->get_list;
	
	$self->{list}->delete('all');
	my $n = 0;
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
	$self->{var_list} = $h;
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
			msg  => '��������ѿ������򤷤Ƥ���������',
		);
		return 0;
	}
	
	# �����˺������Τ���ǧ
	unless ( $args{no_conf} ){
		my $confirm = $self->{win_obj}->messageBox(
			-title   => 'KH Coder',
			-type    => 'OKCancel',
			#-default => 'OK',
			-icon    => 'question',
			-message => $self->gui_jchar('���򤵤�Ƥ����ѿ��������ޤ�����'),
		);
		unless ($confirm =~ /^OK$/i){
			return 0;
		}
	}
	
	# ���˾ܺ�Window�������Ƥ�����Ϥ��ä����Ĥ���
	$::main_gui->get('w_outvar_detail')->close
		if $::main_gui->if_opened('w_outvar_detail');
	
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
			msg  => '���Ϥ����ѿ������򤷤Ƥ���������',
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
				msg  => '����ñ�̤ΰۤʤ��ѿ�������٤���¸���뤳�ȤϤǤ��ޤ���',
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
			$self->gui_jt('��ʸ�����и��ɽ��̾�����դ�����¸'),
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

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	$self->win_obj->after(100,sub{ $self->_chk1_open_var($current, $cn) });
}

sub _chk1_open_var{
	my $self   = shift;
	my $chk    = shift;
	my $chk_n  = shift;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	#print Jcode->new("1: $chk, $chk_n, $current, $cn\n")->sjis ;
	
	if ($chk eq $current && $chk_n == $cn){
		$self->win_obj->after(200,sub{ $self->_chk2_open_var($current, $cn) });
	}
}

sub _chk2_open_var{
	my $self   = shift;
	my $chk    = shift;
	my $chk_n  = shift;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	#print Jcode->new("2: $chk, $chk_n, $current, $cn\n")->sjis ;

	if ($chk eq $current && $chk_n == $cn){
		$self->win_obj->after(50,sub{ $self->_chk3_open_var($current, $cn) });
	}
}

sub _chk3_open_var{
	my $self   = shift;
	my $chk    = shift;
	my $chk_n  = shift;

	my @selection = $self->{list}->info('selection');
	my $current = $self->{var_list}[$selection[0]][1];
	my $cn = @selection;

	#print Jcode->new("2: $chk, $chk_n, $current, $cn\n")->sjis ;

	if ($chk eq $current && $chk_n == $cn){
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
			'���ѿ��ξܺ١� '
			.$self->{var_list}[$selection[0]][1]
		)
	);

	# �ͤȥ�٥��ɽ��
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
		$c->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$c]);
		
		$self->{entry}{$i->[0]} = $c;
		$self->{label}{$i->[0]} = $i->[1];
		++$n;
	}
	gui_hlist->update4scroll($self->{list_val});

	# ����ñ��
	my @tanis   = ();
	if ($self->{opt_tani}){
		$self->{opt_tani}->destroy;
		$self->{opt_tani} = undef;
	}

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

	#gui_window::outvar_detail->open(
	#	tani => $self->{var_list}[$selection[0]][0],
	#	name => $self->{var_list}[$selection[0]][1],
	#);
}

sub _clear_values{
	my $self = shift;
	
	$self->{selected_var_obj} = undef;
	
	$self->{label_name}->configure(
		-text => $self->gui_jchar('���ѿ��ξܺ�')
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
