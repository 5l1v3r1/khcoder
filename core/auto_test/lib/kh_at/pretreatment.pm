package kh_at::pretreatment;
use base qw(kh_at);
use strict;

# �ƥ��Ƚ��Ͽ�: 7

sub _exec_test{
	my $self = shift;
	my $t = '';
	
	# �ָ����з�̤��ǧ��
	gui_window::morpho_check->open;
	my $win_src = $::main_gui->get('w_morpho_check');
	$win_src->entry->insert(0,gui_window->gui_jchar('´�Ⱦڽ�'));
	$win_src->search;
	$t .= "�������з�̤��ǧ:\n".Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win_src->list ) )
	)->euc;
	
	# �ָ����з�̤��ǧ���ܺ١�
	$win_src->list->selectionSet(0);
	$win_src->detail;
	my $win_dtl = $::main_gui->get('w_morpho_detail');
	$t .= "�������з�̤��ǧ�ʾܺ١�:\n".Jcode->new(
		gui_window->gui_jg( gui_hlist->get_all( $win_dtl->list ) ),
		'sjis'
	)->euc;

	# �ָ�μ������ס��ʻ������
	gui_window::dictionary->open;
	my $win_dic1 = $::main_gui->get('w_dictionary');
	$win_dic1->{checks}[3] = 0;
	$win_dic1->{checks}[4] = 0;
	$win_dic1->hlist->update;
	$win_dic1->save;
	$t .= "���ʻ�������ѹ���:\n";
	$t .= "words_all:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{ent_num1}->get )
	)->euc."\n";
	$t .= "project_kinds:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{ent_num2}->get )
	)->euc."\n";

	gui_window::dictionary->open;
	my $win_dic2 = $::main_gui->get('w_dictionary');
	$win_dic2->{checks}[3] = 1;
	$win_dic2->{checks}[4] = 1;
	$win_dic2->hlist->update;
	$win_dic2->save;
	$t .= "���ʻ�����ʺ��ѹ���:\n";
	$t .= "words_all:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{ent_num1}->get )
	)->euc."\n";
	$t .= "project_kinds:\t".Jcode->new(
		gui_window->gui_jg( $::main_gui->inner->{ent_num2}->get )
	)->euc."\n";

	# ��ʣ��̾��Υꥹ�ȡʰ����ˡ�
	#$::main_gui->{menu}->mc_hukugo_exec;
	#my $target = $::project_obj->file_HukugoList;
	#$t .= "��ʣ��̾��Υꥹ��:\n";
	#open (RFILE,"$target") or die;
	#while (<RFILE>){
	#	$t .= Jcode->new($_)->euc;
	#}
	#close (RFILE);
	
	
	$self->{result} = $t;
	return $self;
}

sub test_name{
	return 'pre-processing...';
}

1;