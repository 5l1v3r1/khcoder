package kh_at::cod;
use base qw(kh_at);
use strict;

sub _exec_test{
	my $self = shift;

	# �ƥ��Ȥ˻��Ѥ��륳���ǥ��󥰥롼�롦�ե���������
	$::project_obj->last_codf( $self->file_cod );

	# ñ�㽸��
	my $win = gui_window::cod_count->open;
	$win->{tani_obj}->{raw_opt} = 'bun';
	$win->{tani_obj}->mb_refresh;
	$win->_calc;
	$self->{result} .= "��ñ�㽸�ס�ʸñ��\n";
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ),'reserve_rn' )
	)->euc;
	$win->{tani_obj}->{raw_opt} = 'dan';
	$win->{tani_obj}->mb_refresh;
	$win->_calc;
	$self->{result} .= "��ñ�㽸�ס�����ñ��\n";
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ),'reserve_rn' )
	)->euc;
	$win->{tani_obj}->{raw_opt} = 'h2';
	$win->{tani_obj}->mb_refresh;
	$win->_calc;
	$self->{result} .= "��ñ�㽸�ס�h2ñ��\n";
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ),'reserve_rn' )
	)->euc;

	# �ϡ��ᡦ����Ȥν���
	sub comment_out{
	my $win1 = gui_window::cod_tab->open;
	$win1->{tani_obj}->{raw_opt} = gui_window->gui_jchar('����','euc');
	$win1->{tani_obj}->check;
	$win1->{tani_obj}->{raw_opt2} = gui_window->gui_jchar('H1','euc');
	$win1->{tani_obj}->{opt2}->update;
	$win1->_calc;
	$self->{result} .= "���ϡ��ᡦ����ȡ����H1ñ��\n";
	#require Encode;
	my $t = '';
	foreach my $i (@{$win1->{result}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			#print "$h, ";
			#print "is_utf8: ",Encode::is_utf8($h),"\n";
			++$n;
		}
		$t .= "\n";
		print "\n";
	}
	
	
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;
	
	$win1->{tani_obj}->{raw_opt} = gui_window->gui_jchar('H2','euc');
	$win1->{tani_obj}->check;
	$win1->{tani_obj}->{raw_opt2} = gui_window->gui_jchar('H1','euc');
	$win1->{tani_obj}->{opt2}->update;
	$win1->_calc;
	$self->{result} .= "���ϡ��ᡦ����ȡ�H2��H1ñ��\n";
	$t = '';
	foreach my $i (@{$win1->{result}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;
	
	$win1->{tani_obj}->{raw_opt} = gui_window->gui_jchar('ʸ','euc');
	$win1->{tani_obj}->check;
	$win1->{tani_obj}->{raw_opt2} = gui_window->gui_jchar('H2','euc');
	$win1->{tani_obj}->{opt2}->update;
	$win1->_calc;
	$self->{result} .= "���ϡ��ᡦ����ȡ�ʸ��H2ñ��\n";
	$t = '';
	foreach my $i (@{$win1->{result}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t, 'sjis')->euc;
	$self->{result} .= $t;
	}
	
	# ��������
	my $win2 = gui_window::cod_outtab->open;
	my $t;
	$self->{result} .= "���������ס�����ָ��Ф�1��\n";
	$win2->{tani_obj}->{raw_opt} = 'dan';
	$win2->{tani_obj}->mb_refresh;
	$win2->{var_obj}->{opt_body}->{selection} = 'h1';
	$win2->{var_obj}->{opt_body}->mb_refresh;
	$win2->_calc;
	$t = '';
	foreach my $i (@{$win2->{result}->{display}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new( $t, 'sjis' )->euc;
	$self->{result} .= $t;
	
	$self->{result} .= "���������ס������h1��dan�ˡ�\n";
	$win2->{tani_obj}->{raw_opt} = 'dan';
	$win2->{tani_obj}->mb_refresh;
	$win2->{var_obj}->{opt_body}->{selection} = 1; # �ѿ���ID
	$win2->{var_obj}->{opt_body}->mb_refresh;
	$win2->_calc;
	$t = '';
	foreach my $i (@{$win2->{result}->{display}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;
	
	$self->{result} .= "���������ס�������縫�Ф���h1�ˡ�\n";
	$win2->{tani_obj}->{raw_opt} = 'dan';
	$win2->{tani_obj}->mb_refresh;
	$win2->{var_obj}->{opt_body}->{selection} = 4; # �ѿ���ID
	$win2->{var_obj}->{opt_body}->mb_refresh;
	$win2->_calc;
	$t = '';
	foreach my $i (@{$win2->{result}->{display}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;
	
	$self->{result} .= "���������ס�h2�����縫�Ф���\n";
	$win2->{tani_obj}->{raw_opt} = 'h2';
	$win2->{tani_obj}->mb_refresh;
	$win2->{var_obj}->{opt_body}->{selection} = 4; # �ѿ���ID
	$win2->{var_obj}->{opt_body}->mb_refresh;
	$win2->_calc;
	$t = '';
	foreach my $i (@{$win2->{result}->{display}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;

	$self->{result} .= "���������ס�h2���ָ��Ф�1��\n";
	$win2->{tani_obj}->{raw_opt} = 'h2';
	$win2->{tani_obj}->mb_refresh;
	$win2->{var_obj}->{opt_body}->{selection} = 'h1';
	$win2->{var_obj}->{opt_body}->mb_refresh;
	$win2->_calc;
	$t = '';
	foreach my $i (@{$win2->{result}->{display}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;

	
	# �����ɴִ�Ϣ
	my $win3 = gui_window::cod_jaccard->open;

	$self->{result} .= "�������ɴִ�Ϣ��h2\n";
	$win3->{tani_obj}->{raw_opt} = 'h2';
	$win3->{tani_obj}->mb_refresh;
	$win3->_calc;
	$t = '';
	foreach my $i (@{$win3->{result}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;

	$self->{result} .= "�������ɴִ�Ϣ��dan\n";
	$win3->{tani_obj}->{raw_opt} = 'dan';
	$win3->{tani_obj}->mb_refresh;
	$win3->_calc;
	$t = '';
	foreach my $i (@{$win3->{result}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t,'sjis')->euc;
	$self->{result} .= $t;
	
	# �����ǥ��󥰷�̽񤭽Ф���SPSS��
	my $cod_f_r;
	$cod_f_r = kh_cod::func->read_file($self->file_cod) or die;
	$cod_f_r->cod_out_csv('h2',$self->file_out_tmp_base.'.csv');

	open (RFILE,$self->file_out_tmp_base.'.csv') or die;
	while (<RFILE>){
		$self->{result} .= Jcode->new($_,'sjis')->euc;
	}
	close (RFILE);

	unlink($self->file_out_tmp_base.'.csv');

	# �����ǥ��󥰷�̽񤭽Ф���WordMiner��
	$cod_f_r = '';
	$cod_f_r = kh_cod::func->read_file($self->file_cod) or die;
	$cod_f_r->cod_out_var('h2',$self->file_out_tmp_base.'.csv');

	open (RFILE,$self->file_out_tmp_base.'.csv') or die;
	while (<RFILE>){
		$self->{result} .= Jcode->new($_,'sjis')->euc;
	}
	close (RFILE);

	unlink($self->file_out_tmp_base.'.csv');

	return $self;
}



sub test_name{
	return 'coding rules...';
}

1;