package kh_at::out_var;
use base qw(kh_at);
use strict;

sub _exec_test{
	my $self = shift;
	
	# �����ѿ����ɤ߹��� (1)
	my $win = gui_window::outvar_read::csv->open;
	$win->{entry}->insert(0, $self->file_outvar );
	$win->{tani_obj}->{raw_opt} = 'dan';
	$win->{tani_obj}->mb_refresh;
	$win->_read;

	# �ɤ߹��߷�̤Υ����å�
	$self->{result} .= "���ɤ߹��߷��\n";
	$win = gui_window::outvar_list->open;
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ),'reserve_rn' )
	)->euc;

	# �����ѿ���1�ĺ��
	$win->{list}->selectionSet(3);
	$win->_delete(
		no_conf => 1,
	);
	$self->{result} .= "���ѿ�����η��\n";
	$self->{result} .= Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win->{list} ),'reserve_rn' )
	)->euc;

	# ��٥��Խ�(1)
	$win->{list}->selectionSet(3);
	$win->_open_var;
	#my $win_edit = $::main_gui->get('w_outvar_detail');
	$win->{entry}{0}->insert(0, gui_window->gui_jchar('�ʤ�') );
	$win->{entry}{1}->insert(0, gui_window->gui_jchar('����') );
	$win->_save;

	# ��٥��Խ�(2)
	$win->{list}->selectionSet(2);
	$win->_open_var;
	#my $win_edit = $::main_gui->get('w_outvar_detail');
	$win->{entry}{1}->insert(0, gui_window->gui_jchar('��') );
	$win->{entry}{2}->insert(0, gui_window->gui_jchar('��') );
	$win->{entry}{3}->insert(0, gui_window->gui_jchar('��') );
	$win->_save;
	# ��٥��Խ��η�̤ϡ������ǥ��󥰷�̤�������å�����ġ�

	# �����ѿ����ɤ߹��� (2)
	my $win = gui_window::outvar_read::csv->open;
	$win->{entry}->insert(0, $self->file_outvar2 );
	$win->{tani_obj}->{raw_opt} = 'h1';
	$win->{tani_obj}->mb_refresh;
	$win->_read;

	return $self;
}

sub test_name{
	return 'variables...';
}


1;