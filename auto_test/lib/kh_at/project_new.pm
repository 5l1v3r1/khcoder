package kh_at::project_new;
use base qw(kh_at);
use strict;

sub _exec_test{
	my $self = shift;
	
	# �ץ������Ȥκ���
	gui_window::project_new->open;
	my $win_np = $::main_gui->get('w_new_pro');
	$win_np->{e1}->insert(0,gui_window->gui_jchar($self->file_testdata));
	$win_np->{e2}->insert(0,gui_window->gui_jchar('��ư�ƥ�����Project'));
	$win_np->{ok_btn}->invoke;
	
	# ��μ������
	gui_window::dictionary->open;
	my $win_dic = $::main_gui->get('w_dictionary');
	$win_dic->{t1}->insert('end',gui_window->gui_jchar("��\n���ο�\n����"));
	$win_dic->{t2}->insert('end',gui_window->gui_jchar("����\n�ͤ�"));
	$win_dic->{ok_btn}->invoke;
	
	# �������μ¹�
	$::main_gui->{menu}->mc_morpho;
	
	# ���ä���ץ������Ȥ��Ĥ���
	$::main_gui->{menu}->mc_close_project;
	#}
	
	# �ץ������Ȥ��Խ�
	gui_window::project_open->open;
	my $win_opn = $::main_gui->get('w_open_pro');
	my $n = @{$win_opn->projects->list} - 1;
	$win_opn->{g_list}->selectionClear(0);
	$win_opn->{g_list}->selectionSet($n);

	$win_opn->edit;
	my $win_edt;
	$win_edt = $::main_gui->get('w_edit_pro');
	$win_edt->{e2}->insert('end',gui_window->gui_jchar('���ԡ�'));
	$win_edt->_edit;

	# �ץ������Ȥ򳫤�ľ��
	$win_opn->{g_list}->selectionClear(0);
	$win_opn->{g_list}->selectionSet($n);
	$win_opn->_open;

	return $self;
}



1;