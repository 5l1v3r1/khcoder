package gui_window::main::menu;
use gui_window::main::menu::underline;
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
		-underline => gui_window::main::menu::underline::conv(13),
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
	
	#--------------#
	#   ���ý���   #
	
	$f = $menubar->cascade(
		-label => Jcode->new('���ý���(B)')->sjis,
		-font => "TKFN",
		-underline => gui_window::main::menu::underline::conv(9),
		-tearoff=>'no'
	);
	
	my $f2 = $f->cascade(
			-label => Jcode->new('������ ���̼¹�')->sjis,
			 -font => "TKFN",
			 -tearoff=>'no'
		);
	
		$self->{m_b1_mark} = $f2->command(
				-label => Jcode->new('��μ������')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					gui_window::dictionary->open;
				})},
				-state => 'disable'
			);
	
	
		$self->{m_b2_morpho} = $f2->command(
				-label => Jcode->new('�����ǲ��ϡ�')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					my $w = gui_wait->start;
					kh_morpho->run;
					mysql_ready->first;
					$w->end;
				})},
				-state => 'disable'
			);

		$self->{m_bx_test} = $f2->command(
				-label => Jcode->new('�ƥ���')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					mysql_ready->test;
				})},
				-state => 'disable'
			);




	$self->{m_b_all} = $f->command(
			-label => Jcode->new('������ ���¹�')->sjis,
			-font => "TKFN",
			-command => sub{ $::mw->after(10,\&gui_BatchProcess::go_batch);},
			-state => 'disable'
		);
	
	$f->separator();
	
	$self->{m_b_output} = $f->command(
			-label => Jcode->new('ñ�㽸�פν��ϡ�SPSS��')->sjis,
			-font => "TKFN",
			-command => sub{ $::mw->after(10,\&syukei_exp);},
			-state => 'disable'
	);


	#------------#
	#   �ġ���   #

	$f = $menubar->cascade(
		-label => Jcode->new('�ġ���(T)')->sjis,
		-font => "TKFN",
		-underline => gui_window::main::menu::underline::conv(7),
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
		
		$f3->separator();
		
		$self->{t_word_freq} = $f3->command(
				-label => Jcode->new('�и���� ʬ�ۡ�SPSS��')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					my $target = $::project_obj->file_WordFreq;
					mysql_words->spss_freq($target);
					gui_OtherWin->open($target);
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

		$self->{t_word_print} = $f3->command(
				-label => Jcode->new('�ꥹ�Ȥΰ�����LaTeX��')->sjis,
				-font => "TKFN",
				-command => sub {$mw->after(10,sub{
					mysql_words->make_list();
				})},
				-state => 'disable'
			);

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
		-underline => gui_window::main::menu::underline::conv(7),
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
		'm_bx_test',
		'm_b_all',

		't_sql_select',
		't_sql_do',
		't_word_search',
		't_word_print',
		't_word_list',
		't_word_freq',
	);
	$self->normalize(\@menu0);

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
		if (substr($i,0,2) eq 'm_'){
			$self->{$i}->configure(-state, 'disable');
		}
	}
}

1;
