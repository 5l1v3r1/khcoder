package gui_window::cod_mds;
use base qw(gui_window);

use strict;


#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt('�����ǥ��󥰡�¿��������ˡ�ʥ��ץ�����'));

	my $lf = $win->LabFrame(
		-label       => 'Options',
		-labelside   => 'acrosstop',
		-borderwidth => 2
	)->pack(
		-fill   => 'both',
		-expand => 1
	);

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
		-text => $self->gui_jchar('�����ǥ���ñ�̡�'),
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
		-text => $self->gui_jchar('����������'),
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 0);

	my $f2 = $lf->Frame()->pack(
		-fill   => 'both',
		-expand => 1,
		-padx   => 2,
		-pady   => 2
	);

	$f2->Label(
		-text => $self->gui_jchar('����','euc'),
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
		-text => $self->gui_jchar('��������'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->select_all;});}
	)->pack(-pady => 3);
	$f2_2->Button(
		-text => $self->gui_jchar('���ꥢ'),
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->select_none;});}
	)->pack();

	$lf->Label(
		-text => $self->gui_jchar('�����������ɤ�5�İʾ����򤷤Ʋ�������','euc'),
		-font => "TKFN",
	)->pack(
		-anchor => 'w',
		-padx   => 4,
	);

	# ���르�ꥺ������
	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);
	$f4->Label(
		-text => $self->gui_jchar('��ˡ��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	my $widget = gui_widget::optmenu->open(
		parent  => $f4,
		pack    => {-side => 'left'},
		options =>
			[
				['Classical', 'C'],
				['Kruskal',   'K'],
				['Sammon',    'S'],
			],
		variable => \$self->{method_opt},
	);
	$widget->set_value('K');

	# �ե���ȥ�����
	my $ff = $lf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 4,
	);

	$ff->Label(
		-text => $self->gui_jchar('�ե���ȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_font_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_font_size}->insert(0,'80');

	$ff->Label(
		-text => $self->gui_jchar('%'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$ff->Label(
		-text => $self->gui_jchar('  �ץ�åȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_plot_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_plot_size}->insert(0,'480');

	# OK������󥻥�
	my $f3 = $win->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);

	$f3->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$self->{ok_btn} = $f3->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-state => 'disable',
		-command => sub{ $mw->after(10,sub{$self->_calc;});}
	)->pack(-side => 'right');

	$self->read_cfile;

	return $self;
}

# �����ǥ��󥰥롼�롦�ե�������ɤ߹���
sub read_cfile{
	my $self = shift;
	
	$self->{hlist}->delete('all');
	
	unless (-e $self->cfile ){
		$self->{code_obj} = undef;
		return 0;
	}
	
	my $cod_obj = kh_cod::func->read_file($self->cfile);
	
	unless (eval(@{$cod_obj->codes})){
		$self->{code_obj} = undef;
		return 0;
	}

	my $left = $self->{hlist}->ItemStyle('window',-anchor => 'w');

	my $row = 0;
	foreach my $i (@{$cod_obj->codes}){
		
		$self->{checks}[$row]{check} = 1;
		$self->{checks}[$row]{name}  = $i;
		
		my $c = $self->{hlist}->Checkbutton(
			-text     => gui_window->gui_jchar($i->name,'euc'),
			-variable => \$self->{checks}[$row]{check},
			-command  => sub{ 
				$self->win_obj->after(10,sub{ $self->check_selected_num; });
			},
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
	$self->{code_obj} = $cod_obj;
	
	$self->check_selected_num;
	
	return $self;
}

# �����ɤ�5�İʾ����򤵤�Ƥ��뤫�����å�
sub check_selected_num{
	my $self = shift;
	
	my $selected_num = 0;
	foreach my $i (@{$self->{checks}}){
		++$selected_num if $i->{check};
	}
	
	if ($selected_num >= 5){
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

# �ץ�åȺ�����ɽ��
sub _calc{
	my $self = shift;

	my @selected = ();
	foreach my $i (@{$self->{checks}}){
		push @selected, $i->{name} if $i->{check};
	}

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	# �ǡ�������
	my $r_command;
	unless ( $r_command = $self->{code_obj}->out2r_selected($self->tani,\@selected) ){
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => "�и�����0�Υ����ɤ����ѤǤ��ޤ���"
		);
		$self->close();
		return 0;
	}
	
	# MDS�¹ԤΤ����R���ޥ��
	$r_command .= "\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "row.names(d) <- c(";
	foreach my $i (@{$self->{checks}}){
		my $name = $i->{name}->name;
		substr($name, 0, 2) = ''
			if index($name,'��') == 0
		;
		$r_command .= '"'.$name.'",'
			if $i->{check}
		;
	}
	chop $r_command;
	$r_command .= ")\n";
	
	# ���르�ꥺ���̤Υ��ޥ��
	my $r_command_d = '';
	my $r_command_a = '';
	if ($self->{method_opt} eq 'K'){
		$r_command .= "library(MASS)\n";
		$r_command .= 'c <- isoMDS(dist(d, method = "binary"), k=2)'."\n";
		
		$r_command_d = $r_command;
		$r_command_d .= 'plot(c$points,type="n",xlab="����1",ylab="����2")'."\n";
		$r_command_d .= 'text(c$points, rownames(c$points),';
		$r_command_d .= "cex=$fontsize)\n";
		
		$r_command_a .= 'plot(c$points,xlab="����1", ylab="����2")'."\n";
		$r_command_a .= 'text(c$points, rownames(c$points),pos=1,';
		$r_command_a .= "cex=$fontsize)\n";
		
		$r_command .= $r_command_a;
	}
	elsif ($self->{method_opt} eq 'S'){
		$r_command .= "library(MASS)\n";
		$r_command .= 'c <- sammon(dist(d, method = "binary"), k=2)'."\n";
		
		$r_command_d = $r_command;
		$r_command_d .= 'plot(c$points,type="n",xlab="����1",ylab="����2")'."\n";
		$r_command_d .= 'text(c$points, rownames(c$points),';
		$r_command_d .= "cex=$fontsize)\n";
		
		$r_command_a .= 'plot(c$points,xlab="����1", ylab="����2")'."\n";
		$r_command_a .= 'text(c$points, rownames(c$points),pos=1,';
		$r_command_a .= "cex=$fontsize)\n";
		
		$r_command .= $r_command_a;
	}
	elsif ($self->{method_opt} eq 'C'){
		$r_command .= 'c <- cmdscale( dist(d, method = "binary") )'."\n";
		
		$r_command_d = $r_command;
		$r_command_d .= 'plot(c, type="n", xlab="����1", ylab="����2")'."\n";
		$r_command_d .= 'text(c, rownames(c),';
		$r_command_d .= "cex=$fontsize)\n";
		
		$r_command_a .= 'plot(c, xlab="����1", ylab="����2")'."\n";
		$r_command_a .= 'text(c, rownames(c),pos=1,';
		$r_command_a .= "cex=$fontsize)\n";

		$r_command .= $r_command_a;
	}
	
	# �ץ�åȺ���
	use kh_r_plot;
	my $plot1 = kh_r_plot->new(
		name      => 'codes_MDS',
		command_f => $r_command_d,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => $self->gui_jg( $self->{entry_plot_size}->get ),
	) or return 0;
	my $plot2 = kh_r_plot->new(
		name      => 'codes_MDS_d',
		command_a => $r_command_a,
		command_f => $r_command,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => $self->gui_jg( $self->{entry_plot_size}->get ),
	) or return 0;

	# ���ȥ쥹�ͤμ���
	my $stress;
	if ($self->{method_opt} eq 'K' or $self->{method_opt} eq 'S'){
		$::config_obj->R->send(
			 'str <- paste("khcoder",c$stress, sep = "")'."\n"
			.'print(str)'
		);
		$stress = $::config_obj->R->read;

		if ($stress =~ /"khcoder(.+)"/){
			$stress = $1;
			$stress /= 100 if $self->{method_opt} eq 'K';
			$stress = sprintf("%.3f",$stress);
		} else {
			$stress = undef;
		}
	}

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_cod_mds_plot')){
		$::main_gui->get('w_cod_mds_plot')->close;
	}
	$self->close;
	gui_window::cod_mds_plot->open(
		plots       => [$plot1, $plot2],
		stress      => $stress,
		no_geometry => 1,
	);
	
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
	return 'w_cod_mds';
}
1;