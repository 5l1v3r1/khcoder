package gui_window::doc_search;
use base qw(gui_window);

use Tk;
use kh_cod::search;


#-------------#
#   GUI����   #
#-------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	$win->focus;
	$win->title(Jcode->new('ʸ�񸡺�')->sjis);
	$self->{win_obj} = $win;
	
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
		-text => Jcode->new('������������')->sjis,
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
		-browsecmd        => sub{ $self->clist_check; }
	)->pack(-anchor => 'w', -padx => '4',-pady => '2', -fill => 'both',-expand => 1);

	# �����ǥ��󥰥롼�롦�ե�����
	my %pack0 = (
			-anchor => 'w',
	);
	$self->{codf_obj} = gui_widget::codf->open(
		parent   => $right,
		command  => sub{$self->read_code;},
		r_button => 1,
		pack     => \%pack0,
	);

	# ľ�����ϥե졼��
	my $f3 = $right->Frame()->pack(-fill => 'x', -pady => 6);
	$self->{direct_w_l} = $f3->Label(
		text => Jcode->new('ľ�����ϡ�')->sjis,
		font => "TKFN"
	)->pack(-side => 'left');

	$self->{direct_w_o} = $f3->Optionmenu(
		-options => ['and','or','code'],
		-font    => "TKFN",
		-width   => 4,
		-variable => \$self->{opt_direct},
		-borderwidth=> 1,
	)->pack(-side => 'left');

	$self->{direct_w_e} = $self->{direct_entry} = $f3->Entry(
		-font       => "TKFN",
	)->pack(-side => left, -padx => 2,-fill => 'x',-expand => 1);
	$self->{direct_w_e}->bind(
		"<Key>",
		[\&gui_jchar::check_key_e,Ev('K'),\$self->{direct_w_e}]
	);
	$win->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);

	# �Ƽ索�ץ����
	my $f2 = $right->Frame()->pack(-fill => 'x',-pady => 2);

	$f2->Button(
		-font    => "TKFN",
		-text    => Jcode->new('����')->sjis,
		-command => sub{ $win->after(10,sub{$self->search;});}
	)->pack(-side => 'right',-padx => 4);

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
		text => Jcode->new('����ñ�̡�')->sjis,
		font => "TKFN"
	)->pack(anchor => 'w', side => 'right');

	$f2->Optionmenu(
		-options =>
			[
				[Jcode->new('AND����')->sjis => 'and'],
				[Jcode->new('OR����')->sjis  => 'or']
			],
		-font    => "TKFN",
		-width   => 7,
		-variable => \$self->{opt_method1},
		-borderwidth => 1,
	)->pack(-pady => '1', -side => 'left');

	$f2->Optionmenu(
		-options =>
			[
				[Jcode->new('�и���')->sjis => 'by'],
				[Jcode->new('tf��')->sjis  => 'tf']
			],
		-font    => "TKFN",
		-width   => 7,
		-variable => \$self->{opt_order},
		-borderwidth=> 1,
	)->pack(-padx => 8);

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
		-header           => 0,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 1,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'black',
		-selectbackground => 'cyan',
		-selectmode       => 'single',
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	my $f5 = $rf->Frame()->pack(-fill => 'x');
	
	$self->{status_label} = $rf->Label(
		text       => 'Ready.',
		font       => "TKFN",
		foreground => 'blue'
	)->pack(side => 'right');


	$self->read_code;
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
		-text  => Jcode->new('��ľ������')->sjis,
	);

	# �롼��ե�������ɤ߹���
	unless (-e $self->cfile ){return 0;}
	my $cod_obj = kh_cod::search->read_file($self->cfile) or return 0;
	unless (eval(@{$cod_obj->codes})){return 0;}
	
	my $row = 1;
	foreach my $i (@{$cod_obj->codes}){
		$self->{clist}->add($row,-at => "$row");
		$self->{clist}->itemCreate(
			$row,
			0,
			-text  => Jcode->new($i->name)->sjis,
		);
		++$row;
	}
	$self->{code_obj} = $cod_obj;
	
	$self->clist_check;
	return $self;
}

#----------------------------------#
#   ��ľ�����ϡפ�on/off�ڤ��ؤ�   #
sub clist_check{
	my $self = shift;

	if ( eval( ($self->{clist}->info('selection'))[0] eq '0') ){
		$self->{direct_w_l}->configure(-foreground => 'black');
		$self->{direct_w_o}->configure(-state => 'normal');
		$self->{direct_w_e}->configure(-state => 'normal');
		$self->{direct_w_e}->configure(-background => 'white');
	} else {
		$self->{direct_w_l}->configure(-foreground => 'gray');
		$self->{direct_w_o}->configure(-state => 'disable');
		$self->{direct_w_e}->configure(-state => 'disable');
		$self->{direct_w_e}->configure(-background => 'gray');
	}
}


#--------------#
#   �����¹�   #
#--------------#

sub search{
	my $self = shift;
	
	# ����Υ����å�
	my @selected = $self->{clist}->info('selection');
	unless (@selected){
		my $win = $self->win_obj;
		gui_errormsg->open(
			type   => 'msg',
			msg    => Jcode->new('�����ɤ����򤵤�Ƥ��ޤ���')->sjis,
			window => \$win,
		);
		return 0;
	}
	
	# ľ��������ʬ���ɤ߹���
	my $direct;
	if ( eval( ($self->{clist}->info('selection'))[0] eq '0') ){
		
	}
	$self->{code_obj}->add_direct($direct);
	
	# �������å��θƤӽФ��ʸ����¹ԡ�
	my $result = $self->{code_obj}->search(
		selected => \@selected,
		tani     => $self->tani,
		method   => $self->{opt_method1},
		order    => $self->{opt_order},
	);
	
	
	
}


#--------------#
#   ��������   #
#--------------#

sub cfile{
	my $self = shift;
	$self->{codf_obj}->cfile;
}

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub win_name{
	return 'w_doc_search';
}

1;