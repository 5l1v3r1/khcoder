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
			-accelerator => 'ECS'
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
					my $ans = $mw->messageBox(
						-message => Jcode->new
							(
							   "���֤Τ����������¹Ԥ��褦�Ȥ��Ƥ��ޤ���\n".
							   "³�Ԥ��Ƥ�����Ǥ�����"
							)->sjis,
						-icon    => 'question',
						-type    => 'OKCancel',
						-title   => 'KH Coder'
					);
					unless ($ans =~ /ok/i){ return 0; }
					
					my $w = gui_wait->start;
					
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

		$self->{m_b1_hukugo} = $f->command(
				-label => Jcode->new('ʣ��̾��Υꥹ�ȡʰ�����')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					my $target = $::project_obj->file_HukugoList;
					unless (-e $target){
						my $ans = $mw->messageBox(
							-message => Jcode->new
								(
								   "���֤Τ����������¹Ԥ��褦�Ȥ��Ƥ��ޤ���"
								   ."������������û���֤ǽ�λ���ޤ���\n".
								   "³�Ԥ��Ƥ�����Ǥ�����"
								)->sjis,
							-icon    => 'question',
							-type    => 'OKCancel',
							-title   => 'KH Coder'
						);
						unless ($ans =~ /ok/i){ return 0; }
						use mysql_hukugo;
						mysql_hukugo->run_from_morpho($target);
					}
					gui_OtherWin->open($target);
				})},
				-state => 'disable'
			);

		$f->separator();

		$self->{m_b3_check} = $f->command(
				-label => Jcode->new('�����з�̤��ǧ')->sjis,
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
				-label => Jcode->new('���󥳡����󥹡�KWIC��')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::word_conc->open;
				})},
				-state => 'disable'
			);
		$f3->separator;
		
		
		$self->{t_word_freq} = $f3->command(
				-label => Jcode->new('�и���� ʬ��')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::word_freq->open->count;
				})},
				-state => 'disable'
			);

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
		

	my $f8 = $f->cascade(
			-label => Jcode->new('ʸ��')->sjis,
			 -font => "TKFN",
			 -tearoff=>'no'
		);

		$self->{t_doc_search} = $f8->command(
				-label => Jcode->new('����')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::doc_search->open;
				})},
				-state => 'disable'
			);

		$self->{m_b3_crossout} = $f8->cascade(
				-label => Jcode->new("��ʸ�����и��ɽ�ν���",'euc')->sjis,
				-font => "TKFN",
				-state => 'disable',
				-tearoff=>'no'
			);
		
			$self->{m_b3_crossout_csv} = $self->{m_b3_crossout}->command(
				-label => Jcode->new("CSV�ե�����")->sjis,
				-font  => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::morpho_crossout::csv->open;
				})},
			);

			$self->{m_b3_crossout_spss} = $self->{m_b3_crossout}->command(
				-label => Jcode->new("SPSS�ե�����")->sjis,
				-font  => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::morpho_crossout::spss->open;
				})},
			);

	my $f5 = $f->cascade(
			-label => Jcode->new('�����ǥ���')->sjis,
			 -font => "TKFN",
			 -tearoff=>'no'
		);

		$self->{t_cod_count} = $f5->command(
			-label => Jcode->new('ñ�㽸��')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::cod_count->open;
				})},
			-state => 'disable'
		);

		$self->{t_cod_tab} = $f5->command(
			-label => Jcode->new('�ϡ��ᡦ����Ȥν���')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::cod_tab->open;
				})},
			-state => 'disable'
		);

		$self->{t_cod_outtab} = $f5->command(
			-label => Jcode->new('�����ѿ��ȤΥ�������')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::cod_outtab->open;
				})},
			-state => 'disable'
		);

		$self->{t_cod_jaccard} = $f5->command(
			-label => Jcode->new('�����ɴִ�Ϣ')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::cod_jaccard->open;
				})},
			-state => 'disable'
		);

		$f5->separator();

		$self->{t_cod_out} = $f5->cascade(
			-label => Jcode->new('�����ǥ��󥰷�̤ν���')->sjis,
			 -font => "TKFN",
			 -tearoff=>'no'
		);

			$self->{t_cod_out_spss} = $self->{t_cod_out}->command(
				-label => Jcode->new('SPSS�ե�����')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
						gui_window::cod_out::spss->open;
					})},
				-state => 'disable'
			);

			$self->{t_cod_out_csv} = $self->{t_cod_out}->command(
				-label => Jcode->new('CSV�ե�����')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
						gui_window::cod_out::csv->open;
					})},
				-state => 'disable'
			);

	$f->separator();
	
	my $f_out_var = $f->cascade(
		-label => Jcode->new('�����ѿ�')->sjis,
		 -font => "TKFN",
		 -tearoff=>'no'
	);
	
		$self->{t_out_read} = $f_out_var->command(
			-label => Jcode->new('CSV�ե����뤫���ɤ߹���')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::outvar_read->open;
				})},
			-state => 'disable'
		);
	
		$self->{t_out_list} = $f_out_var->command(
			-label => Jcode->new('�ѿ��ꥹ�ȡ��ͥ�٥�')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::outvar_list->open;
				})},
			-state => 'disable'
		);
	
	my $f6 = $f->cascade(
		-label => Jcode->new('�ƥ����ȥե�������ѷ�')->sjis,
		 -font => "TKFN",
		 -tearoff=>'no'
	);

		$self->{t_txt_pickup} = $f6->command(
			-label => Jcode->new('��ʬ�ƥ����Ȥμ��Ф�')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::txt_pickup->open;
				})},
			-state => 'disable'
		);

		$self->{t_txt_html2mod} = $f6->command(
			-label => Jcode->new('HTML����CSV���Ѵ�')->sjis,
			-font => "TKFN",
			-command => sub {$mw->after(10,sub{
					gui_window::txt_html2csv->open;
				})},
			-state => 'disable'
		);


	my $f2 = $f->cascade(
			-label => Jcode->new('SQLʸ ����')->sjis,
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
		
		$msg = Jcode->new('KH Coder�ˤĤ���','euc')->sjis;
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
		'm_b1_hukugo',
	);

	# �����ǲ��Ϥ��Ԥ��Ƥ����Active
	my @menu1 = (
		't_word_search',
		't_word_list',
		't_word_freq',
		't_word_conc',
		'm_b3_check',
		't_cod_count',
		't_cod_tab',
		't_cod_jaccard',
		't_cod_out',
		't_cod_outtab',
		't_cod_out_spss',
		't_cod_out_csv',
		't_txt_html2mod',
		'm_b3_crossout',
		'm_b3_crossout_csv',
		'm_b3_crossout_spss',
		't_txt_pickup',
		't_doc_search',
		't_out_read',
		't_out_list',
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
