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
	$win_np->_make_new;
	
	# ��μ������
	gui_window::dictionary->open;
	my $win_dic = $::main_gui->get('w_dictionary');
	$win_dic->{t1}->insert('end',gui_window->gui_jchar("��\n���ο�\n����"));
	$win_dic->{t2}->insert('end',gui_window->gui_jchar("����\n�ͤ�"));
	$win_dic->save;
	
	# �������μ¹�
	$::main_gui->{menu}->mc_morpho_exec;
	
	# ���ä���ץ������Ȥ��Ĥ���
	$::main_gui->{menu}->mc_close_project;
	
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

	# �ƥ��ȷ�̤μ���
	my $t = '';
	$t .= "��project_name:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{e_curent_project}->get )
	)->euc."\n";
	$t .= "��project_comment:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{e_project_memo}->get )
	)->euc."\n";
	$t .= "��words_all:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{ent_num1}->get )
	)->euc."\n";
	$t .= "��project_kinds:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{ent_num2}->get )
	)->euc."\n";
	$t .= "��doc num:\n".Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $::main_gui->inner->hlist ) )
	)->euc;

	$self->{result} = $t;

	return $self;
}

sub test_name{
	return 'Create / Close / Edit / Open project...';
}


1;