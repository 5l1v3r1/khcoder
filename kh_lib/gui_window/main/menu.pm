package gui_window::main::menu;
use strict;

#------------------#
#   ��˥塼����   #
#------------------#

sub make{
	my $class = shift;
	my $gui   = shift;
	my $self;
	
	my $mw = ${$gui}->mw;
	my $toplevel = $mw->toplevel;
	my $menubar = $toplevel->Menu(-type => 'menubar');
	$toplevel->configure(-menu => $menubar);


	#------------------#
	#   �ץ�������   #
	
	my $msg = Jcode->new('�ץ�������(P)','euc')->sjis;
	my $f = $menubar->cascade(
		-label => "$msg",
		-font => "TKFN",
		-underline => $::config_obj->underline_conv(13),
		-tearoff=>'no'
	);

		$msg = Jcode->new('����','euc')->sjis;
		$f->command(
			-label => $msg,
			-font => "TKFN",
			-command =>
				sub{ $mw->after(10,sub{gui_window::project_new->open;});},
			-accelerator => 'Ctrl+N'
		);
		$msg = Jcode->new('����','euc')->sjis;
		$f->command(
			-label => $msg,
			-font => "TKFN",
			-command =>
				sub{ $mw->after(10,sub{gui_window::project_open->open;});},
			-accelerator => 'Ctrl+O'
		);
		$self->{m_b0_close} = $f->command(
			-label => Jcode->new('�Ĥ���')->sjis,
			-font => "TKFN",
			-state => 'disable',
			-command =>
				sub{ $mw->after(10,sub{
					$::main_gui->close_all;
					undef $::project_obj;
					$::main_gui->menu->refresh;
					$::main_gui->inner->refresh;
				});},
		);
		
		
		$f->separator();
		$msg = Jcode->new('����','euc')->sjis;
		$f->command(
			-label => $msg,
			-font => "TKFN",
			-command => 
				sub{ $mw->after(10,sub{gui_window::sysconfig->open;});},
		);
		$f->separator();
		$msg = Jcode->new('��λ','euc')->sjis;
		$f->command(
			-label => $msg,
			-font => "TKFN",
			-command => sub{ $mw->after(10,sub{exit;});},
			-accelerator => 'Ctrl+Q'
		);

	#------------#
	#   ������   #
	
	$f = $menubar->cascade(
		-label => Jcode->new('������(B)')->sjis,
		-font => "TKFN",
		-underline => $::config_obj->underline_conv(7),
		-tearoff=>'no'
	);

		$self->{m_b2_morpho} = $f->command(
				-label => Jcode->new('�������μ¹�')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					
					my $w = gui_wait->start;
					kh_morpho->run;
					mysql_ready->first;
					$::project_obj->status_morpho(1);
					$w->end;
					$::main_gui->menu->refresh;
					$::main_gui->inner->refresh;
				})},
				-state => 'disable'
			);
		$f->separator();
		$self->{m_b1_mark} = $f->command(
				-label => Jcode->new('��μ������')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::dictionary->open;
				})},
				-state => 'disable'
			);

		$self->{m_b3_check} = $f->command(
				-label => Jcode->new('�����ǲ��Ϸ�̤γ�ǧ')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::morpho_check->open;
				})},
				-state => 'disable'
			);

	#------------#
	#   �ġ���   #

	$f = $menubar->cascade(
		-label => Jcode->new('�ġ���(T)')->sjis,
		-font => "TKFN",
		-underline => $::config_obj->underline_conv(7),
		-tearoff=>'no'
	);

	my $f3 = $f->cascade(
			-label => Jcode->new('��и�')->sjis,
			 -font => "TKFN",
			 -tearoff=>'no'
		);

		$self->{t_word_search} = $f3->command(
				-label => Jcode->new('����')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::word_search->open;
				})},
				-state => 'disable'
			);

		$self->{t_word_conc} = $f3->command(
				-label => Jcode->new('���󥳡����� [KWIC]')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::word_conc->open;
				})},
				-state => 'disable'
			);
		$f3->separator();

		$self->{t_word_list} = $f3->command(
				-label => Jcode->new('�ʻ��� �и������ �ꥹ��')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					my $target = $::project_obj->file_WordList;
					mysql_words->csv_list($target);
					gui_OtherWin->open($target);
				})},
				-state => 'disable'
			);

		$f3->separator();
		
		$self->{t_word_freq} = $f3->command(
				-label => Jcode->new('�и���� ʬ�� (SPSS)')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					my $target = $::project_obj->file_WordFreq;
					mysql_words->spss_freq($target);
					gui_OtherWin->open($target);
				})},
				-state => 'disable'
			);
		


		#$self->{t_word_print} = $f3->command(
		#		-label => Jcode->new('�ꥹ�Ȥΰ�����LaTeX��')->sjis,
		#		-font => "TKFN",
		#		-command => sub {$mw->after(10,sub{
		#			mysql_words->make_list();
		#		})},
		#		-state => 'disable'
		#	);


	my $f2 = $f->cascade(
			-label => Jcode->new('SQL���ޥ������')->sjis,
			 -font => "TKFN",
			 -tearoff=>'no'
		);
	
		$self->{t_sql_select} = $f2->command(
				-label => Jcode->new('SELECT')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::sql_select->open;
				})},
				-state => 'disable'
			);

		$self->{t_sql_do} = $f2->command(
				-label => Jcode->new('����¾')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::sql_do->open;
				})},
				-state => 'disable'
			);



	#------------#
	#   �إ��   #
	
	$msg = Jcode->new('�إ��(H)','euc')->sjis;
	$f = $menubar->cascade(
		-label => "$msg",
		-font => "TKFN",
		-underline => $::config_obj->underline_conv(7),
		-tearoff=>'no'
	);
	
		$msg = Jcode->new('�����������PDF������','euc')->sjis;
		$f->command(
			-label => $msg,
			-font => "TKFN",
			-command => sub{ $mw->after
				(
					10,
					sub { gui_OtherWin->open('kh_coder_manual.pdf'); }
				);
			},
		);
		
		$msg = Jcode->new('�ǿ�����','euc')->sjis;
		$f->command(
			-label => $msg,
			-font => "TKFN",
			-command =>sub{ $mw->after
				(
					10,
					sub {
					 gui_OtherWin->open('http://koichi.nihon.to/psnl/khcoder');
					}
				);
			},
		);
		
		$msg = Jcode->new('KH Coder II �ˤĤ���','euc')->sjis;
		$f->command(
			-label => $msg,
			-command => sub{ $mw->after(10, sub{gui_window::about->open;});},
			-font => "TKFN"
		);

	#--------------------#
	#   �������Х����   #
	
	$mw->bind(
		'<Control-Key-o>',
		sub{ $mw->after(10,sub{gui_window::project_open->open;});}
	);
	$mw->bind(
		'<Control-Key-n>',
		sub{ $mw->after(10,sub{gui_window::project_new->open;});}
	);

	bless $self, $class;
	return $self;
}

#------------------------#
#   ��˥塼�ξ����ѹ�   #
#------------------------#
sub refresh{
	my $self = shift;
	$self->disable_all;
	
	
	# �ץ������Ȥ����򤵤���Active
	my @menu0 = (
		'm_b1_mark',
		'm_b2_morpho',
		't_sql_select',
		't_sql_do',
		'm_b0_close',
	);

	# �����ǲ��Ϥ��Ԥ��Ƥ����Active
	my @menu1 = (
		't_word_search',
		# 't_word_print',
		't_word_list',
		't_word_freq',
		't_word_conc',
		'm_b3_check',
	);

	# �����ѹ�
	if ($::project_obj){
		$self->normalize(\@menu0);
		if ($::project_obj->status_morpho){
			$self->normalize(\@menu1);
		}
	}

}

sub normalize{
	my $self = shift;
	foreach my $i (@{$_[0]}){
		$self->{$i}->configure(-state,'normal');
	}
}


# ����Disable
sub disable_all{
	my $self = shift;
	foreach my $i (keys %{$self}){
		if (substr($i,0,2) eq 'm_' || substr($i,0,2) eq 't_'){
			$self->{$i}->configure(-state, 'disable');
		}
	}
}

1;
