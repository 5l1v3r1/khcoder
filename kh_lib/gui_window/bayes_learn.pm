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

	my $fcv = $lf_x->Frame()->pack(-fill => 'x', -expand => 0);

	$self->{chkw_cross} = $fcv->Checkbutton(
			-text     => $self->gui_jchar('����������Ԥ�','euc'),
			-variable => \$self->{check_cross},
			-anchor => 'w',
			-command => sub {$self->w_status;},
	)->pack(-anchor => 'w', -side => 'left');
	
	$self->{label_fold} = $fcv->Label(
		-text       => '  Folds:',
		#-foreground => 'gray',
	)->pack(-anchor => 'w', -side => 'left');
	
	$self->{entry_fold} = $fcv->Entry(
		-width      => 3,
		-state      => 'normal',
	)->pack(-anchor => 'w', -side => 'left');
	
	$self->{entry_fold}->insert(0,10);
	# gui_window->disabled_entry_configure($self->{entry_fold});
	$self->{entry_fold}->configure(-state => 'disable');

	$win->Button(
		-text    => $self->gui_jchar('����󥻥�'),
		-font    => "TKFN",
		-width   => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text    => 'OK',
		-width   => 8,
		-font    => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->calc;});}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');

	$self->w_status;
	return $self;
}

	sub w_status{
		my $self = shift;
		if ( $self->{check_cross} ){
			$self->{entry_fold}->configure(-state => 'normal');
			$self->{label_fold}->configure(-state => 'normal');
		} else {
			$self->{entry_fold}->configure(-state => 'disable');
			$self->{label_fold}->configure(-state => 'disable');
		}
	}

sub calc{
	my $self = shift;
	
	#------------------#
	#   ���ϥ����å�   #

	my $fold = $self->gui_jg( $self->{entry_fold}->get );
	if (
		   $fold =~ /[^0-9]/o
		|| $fold < 2
		|| $fold > 20
	){
		gui_errormsg->open(
			type => 'msg',
			msg  => 'Fold�ˤ�2����20�ޤǤ��ͤ���ꤷ�Ʋ�������',
		);
		return 0;
	}

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

	my $r = kh_nbayes->learn_from_ov(
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
		cross_fl => $fold,
	);

	my $msg = '';
	$msg .= "�ʥ����֥٥���ʬ���γؽ�����λ���ޤ�����\n\n";
	$msg .= "����ؽ�����ʸ��: $r->{instances}";
	if ($self->{check_overwrite}){
		$msg .= ", ʸ������: $r->{instances_all}\n";
	} else {
		$msg .= "\n";
	}
	if ($self->{check_cross}){
		$msg .= "ʬ������Τ�: $r->{cross_vl_ok} / $r->{cross_vl_tested} (";
		$msg .= sprintf("%.1f",$r->{cross_vl_ok}/$r->{cross_vl_tested}*100);
		$msg .= "%),  ";
		$msg .= "Kappa: ";
		$msg .= sprintf("%.3f",$r->{kappa});
		
	}

	gui_errormsg->open(
		type => 'msg',
		msg  => $msg,
		icon => 'info',
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