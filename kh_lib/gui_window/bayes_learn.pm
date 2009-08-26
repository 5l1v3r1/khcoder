package gui_window::bayes_learn;
use base qw(gui_window);
use strict;
use Tk;

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt('�����ѿ�����ؽ�'));

	my $lf_w = $win->LabFrame(
		-label => 'Basic Settings',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);

	$self->{words_obj} = gui_widget::words_bayes->open(
		parent => $lf_w,
		verb   => '�ؽ��˻���',
	);

	my $lf_x = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0);

	$self->{chkw_over} = $lf_x->Checkbutton(
			-text     => $self->gui_jchar('��¸�γؽ���̥ե�����˺�������Ƥ��ɲä���','euc'),
			-variable => \$self->{check_overwrite},
			-anchor => 'w',
			-command => sub {$self->w_status;},
	)->pack(-anchor => 'w');

	$self->{chkw_cross} = $lf_x->Checkbutton(
			-text     => $self->gui_jchar('����������Ԥ�','euc'),
			-variable => \$self->{check_cross},
			-anchor => 'w',
			-command => sub {$self->w_status;},
	)->pack(-anchor => 'w');

	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->calc;});}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');

	return $self;
}

	sub w_status{
		return 1;
		# �ɵ��ȸ򺹤���¾�ˤ���ʤ�ʲ��Υ����ɤ�褫��
		my $self = shift;
		if ($self->{check_overwrite}){
			$self->{chkw_cross}->configure(-state => 'disable');
		} else {
			$self->{chkw_cross}->configure(-state => 'normal');
		}
		if ( $self->{check_cross} ){
			$self->{chkw_over}->configure(-state => 'disable');
		} else {
			$self->{chkw_over}->configure(-state => 'normal');
		}
	}

sub calc{
	my $self = shift;
	
	#------------------#
	#   ���ϥ����å�   #

	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}

	if ( $self->outvar == -1 ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�����ѿ������꤬�����Ǥ�����',
		);
		return 0;
	}

	$self->{words_obj}->settings_save;

	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��ޤ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	unless ($ans =~ /ok/i){ return 0; }

	# ��¸��λ���
	my @types = (
		[ "KH Coder: Naive Bayes Moldels",[qw/.knb/] ],
		["All files",'*']
	);

	my $path;
	if ( $self->{check_overwrite} ){
		$path = $self->win_obj->getOpenFile(
			-defaultextension => '.knb',
			-filetypes        => \@types,
			-title            =>
				$self->gui_jt('����γؽ����Ƥ��ɲä���ե����������'),
			-initialdir       => $self->gui_jchar($::config_obj->cwd),
		);
	} else {
		$path = $self->win_obj->getSaveFile(
			-defaultextension => '.knb',
			-filetypes        => \@types,
			-title            =>
				$self->gui_jt('�ؽ���̤򿷵��ե��������¸'),
			-initialdir       => $self->gui_jchar($::config_obj->cwd),
		);
	}

	unless ($path){
		return 0;
	}
	$path = gui_window->gui_jg_filename_win98($path);
	$path = gui_window->gui_jg($path);
	$path = $::config_obj->os_path($path);

	#----------#
	#   �¹�   #

	unless ( $self->{words_obj}->check > 0 ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���ߤ��������ƤǤϡ����ѤǤ���줬����ޤ���',
		);
		return 0;
	}

	use kh_nbayes;

	my $n = kh_nbayes->learn_from_ov(
		tani     => $self->tani,
		outvar   => $self->outvar,
		hinshi   => $self->hinshi,
		max      => $self->max,
		min      => $self->min,
		max_df   => $self->max_df,
		min_df   => $self->min_df,
		path     => $path,
		add_data => $self->{check_overwrite},
		cross_vl => $self->{check_cross},
	);

	gui_errormsg->open(
		type => 'msg',
		msg  => "�ؽ�����λ���ޤ�����\n�ؽ����Ѥ���ʸ��ο�: $n",
	);

	$self->close;
	return 1;
}

#--------------#
#   ��������   #

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
sub outvar{
	my $self = shift;
	return $self->{words_obj}->outvar;
}

sub win_name{
	return 'w_bayes_learn';
}

1;