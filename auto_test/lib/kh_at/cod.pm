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
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ) )
	)->euc;
	$win->{tani_obj}->{raw_opt} = 'dan';
	$win->{tani_obj}->mb_refresh;
	$win->_calc;
	$self->{result} .= "��ñ�㽸�ס�����ñ��\n";
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ) )
	)->euc;
	$win->{tani_obj}->{raw_opt} = 'h2';
	$win->{tani_obj}->mb_refresh;
	$win->_calc;
	$self->{result} .= "��ñ�㽸�ס�h2ñ��\n";
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ) )
	)->euc;

	# �ϡ��ᡦ����Ȥν���
	my $win1 = gui_window::cod_tab->open;
	$win1->{tani_obj}->{raw_opt} = gui_window->gui_jchar('����','euc');
	$win1->{tani_obj}->check;
	$win1->{tani_obj}->{raw_opt2} = gui_window->gui_jchar('H1','euc');
	$win1->{tani_obj}->{opt2}->update;
	$win1->_calc;
	$self->{result} .= "���ϡ��ᡦ����ȡ����H1ñ��\n";
	my $t = '';
	foreach my $i (@{$win1->{result}}){
		my $n = 0;
		foreach my $h (@{$i}){
			$t .= "\t" if $n;
			$t .= $h;
			++$n;
		}
		$t .= "\n";
	}
	$t = Jcode->new($t)->euc;
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
	$t = Jcode->new($t)->euc;
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
	$t = Jcode->new($t)->euc;
	$self->{result} .= $t;
	
	
	return $self;
}



sub test_name{
	return 'coding rules...';
}

1;