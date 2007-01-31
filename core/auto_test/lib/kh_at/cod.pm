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


	return $self;
}



sub test_name{
	return 'Coding...';
}

1;