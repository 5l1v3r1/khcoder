package p4_read_hinshi_setting;
use strict;

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		name     => '�ʻ������ץ������Ȥ��ɤ߹���',
		menu_cnf => 1,
		menu_grp => '',
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{

	my $ans = $::main_gui->mw->messageBox(
		-message => gui_window->gui_jchar
			(
				 "KH Coder���ʻ�����򡢸��߳����Ƥ���ץ������Ȥ��ɤ߹��ߤޤ���\n\n"
				."��KH Coder���ʻ�������ѹ����Ƥ⡢��������Ԥ�ʤ������ꡢ\n"
				."��¸�Υץ������Ȥ��ʻ�����Ϲ�������ޤ���\n\n"
				."³�Ԥ��Ƥ�����Ǥ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	return 0 unless $ans =~ /ok/i;

	$::project_obj->read_hinshi_setting;

	gui_errormsg->open(
		msg  => 
			 '���߳����Ƥ���ץ������Ȥ��ʻ�����򹹿����ޤ�����'
			."\n"
			.'�ʻ�������ѹ���ȿ�Ǥ���ˤϡʺ��١���������¹Ԥ��Ʋ�������',
		type => 'msg',
		icon => 'info',
	);
}
1;
