package gui_window::txt_pickup;
use base qw(gui_window);

use strict;

use kh_cod::pickup;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	#$win->focus;
	$win->title($self->gui_jchar('��ʬ�ƥ����Ȥμ��Ф�'));
	#$self->{win_obj} = $win;

	#----------------------#
	#   ���Ф��μ��Ф�   #

	my $radio_head = $win->Radiobutton(
		-text             => $self->gui_jchar('���Ф�ʸ��������Ф�'),
		-font             => "TKFN",
		-foreground       => 'blue',
		-activeforeground => 'red',
		-variable         => \$self->{radio},
		-value            => 'head',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $lf = $win->LabFrame(
		-label => 'Heading',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');
	
	$self->{l_h_1} = $lf->Label(
		-text => $self->gui_jchar('�����Ф����Ф�������'),
		-font => "TKFN"
	)->pack(-anchor => 'w');
	my $f1 = $lf->Frame->pack(-fill => 'x');
	$f1->Label(
		-text => $self->gui_jchar('����'),
		-font => "TKFN",
	)->pack(-side => 'left', -padx => 2);
	foreach my $i ('H1','H2','H3','H4','H5'){
		$self->{"check_w_"."$i"} = $f1->Checkbutton(
			-text     => "$i".$self->gui_jchar('���Ф�','euc'),
			-font     => "TKFN",
			-variable => \$self->{"check_v_"."$i"},
		)->pack(-side => 'left', -padx => 4)
	}
	
	#--------------------------#
	#   �����ǥ��󥰡��롼��   #
	
	$win->Radiobutton(
		-text             => $self->gui_jchar('����Υ����ɤ�Ϳ����줿ʸ���������Ф�'),
		-font             => "TKFN",
		-foreground       => 'blue',
		-activeforeground => 'red',
		-variable         => \$self->{radio},
		-value            => 'code',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w');

	my $cf = $win->LabFrame(
		-label => 'Coded doc',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 'y');

	my $left = $cf->Frame()->pack(-side => 'left',-fill=>'y',-expand => 1);
	my $right = $cf->Frame()->pack(-side => 'right');

	$self->{l_c_1} = $left->Label(
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
		-background       => 'white',
		-height           => '6',
		-width            => '20',
		-selectforeground => 'brown',
		-selectbackground => 'cyan',
	#	-activebackground=> 'cyan',
		-selectmode=> 'single'
	)->pack(-anchor => 'w', -padx => '4',-pady => '2', -fill => 'y',-expand => 1);

	$self->{codf_obj} = gui_widget::codf->open(
		parent  => $right,
		command => sub{$self->read_code;}
	);
	my $f2 = $right->Frame()->pack(-fill => 'x',-pady => 8);
	$self->{l_c_2} = $f2->Label(
		-text => $self->gui_jchar('�����ǥ���ñ�̡�'),
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');
	my %pack = (
			-anchor => 'e',
			-pady   => 1,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f2,
		pack   => \%pack
	);
	$self->{ch_w_high} = $right->Checkbutton(
		-text     => $self->gui_jchar('����̤θ��Ф��򿷵��ƥ����ȥե�����˴ޤ��'),
		-font     => "TKFN",
		-variable => \$self->{ch_v_high},
	)->pack(-anchor => 'w');
	$self->{ch_w_high}->select;



	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->save;});}
	)->pack(-side => 'right');
	
	$radio_head->invoke;
	return $self;
}

#-------------------#
#   GUI�ξ����ѹ�   #

sub refresh{
	my $self = shift;
	
	if ($self->{radio} eq 'head') {
		$self->{l_h_1}->configure(-foreground => 'black');
		$self->{l_c_1}->configure(-foreground => 'gray');
		$self->{l_c_2}->configure(-foreground => 'gray');
		$self->{ch_w_high}->configure(-state => 'disable');
		$self->{clist}->configure(-background => 'gray');
		$self->{clist}->configure(-selectbackground => 'gray');
		$self->{tani_obj}->disable;
		$self->{codf_obj}->disable;
	} else {
		$self->{l_h_1}->configure(-foreground => 'gray');
		$self->{l_c_1}->configure(-foreground => 'black');
		$self->{l_c_2}->configure(-foreground => 'black');
		$self->{ch_w_high}->configure(-state => 'normal');
		$self->{clist}->configure(-background => 'white');
		$self->{clist}->configure(-selectbackground => 'cyan');
		$self->{tani_obj}->normal;
		$self->{codf_obj}->normal;
		$self->read_code;
	}
	
	
	# ���Ф����Ф���ʬ�ʸ��Ф������뤫�ɤ���������å���
	foreach my $i ("h5","h4","h3","h2","h1"){
		my $h = $i;
		$h =~ tr/h/H/;
		if (
			$self->{radio} eq 'head'
			&&
			mysql_exec->select(
				"select status from status where name = \'$i\'",1
			)->hundle->fetch->[0]
		){
			$self->{"check_w_"."$h"}->configure(-state => 'normal');
		} else {
			$self->{"check_w_"."$h"}->configure(-state => 'disable');
		}
	}
}

# �����ǥ��󥰥롼�롦�ե�������ɤ߹���

sub read_code{
	my $self = shift;
	
	$self->{clist}->delete('all');
	unless (-e $self->cfile ){return 0;}
	
	my $cod_obj = kh_cod::pickup->read_file($self->cfile) or return 0;
	unless (eval(@{$cod_obj->codes})){return 0;}
	my $row = 0;
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
	return $self;
}


#--------------#
#   ��������   #
#--------------#


sub save{
	my $self = shift;
	if ($self->{radio} eq 'head'){
		$self->_head;
	} else {
		$self->_cod;
	}
}

#------------------------------------------#
#   �����ɤ�Ϳ����줿�ƥ����Ȥμ��Ф�   #

sub _cod{
	my $self = shift;
	
	if ( $self->{clist}->info('selection') eq '' ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�����ɤ����򤵤�Ƥ��ޤ���'
		);
		return 0;
	}
	my $selected = $self->gui_jg( $self->{clist}->info('selection') );
	
	my $path = $self->get_path or return 0;
	
	$self->{code_obj}->pick(
		file     => $path,
		selected => $selected,
		tani     => $self->tani,
		pick_hi  => $self->{ch_v_high},
	);
	
	$self->close;
}

#----------------------#
#   ���Ф��μ��Ф�   #

sub _head{
	my $self = shift;
	
	# ���Ф����Ф��Υ����å�
	my %midashi;
	my $n;
	foreach my $i ('H1','H2','H3','H4','H5'){
		if ($self->{"check_v_"."$i"}){
			my $h = $i;
			$h =~ tr/H/h/;
			$midashi{$h} = 1;
			++$n;
		}
	}
	unless ($n){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���Ф����Ф������򤵤�Ƥ��ޤ���'
		);
		return 0;
	}
	
	my $path = $self->get_path or return 0;

	mysql_getheader->get_all(
		file     => $path,
		pic_head => \%midashi,
	);
	
	$self->close;
}

#------------------#
#   ��¸��λ���   #

sub get_path{
	my $self = shift;
	
	my @types = (
		[ "text file",[qw/.txt/] ],
		["All files",'*']
	);
	return $self->gui_jg(
		$self->win_obj->getSaveFile(
			-defaultextension => '.txt',
			-filetypes        => \@types,
			-title            =>
				$self->gui_jchar('��ʬ�ƥ����Ȥμ��Ф���̾�����դ�����¸'),
			-initialdir       => $::config_obj->cwd
		)
	);
}


#--------------#
#   ��������   #

sub cfile{
	my $self = shift;
	$self->{codf_obj}->cfile;
}

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub win_name{
	return 'w_txt_pickup';
}

1;