package p4_read_hinshi_setting;
use strict;

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		name     => '�ʻ�������ɤ߹���',
		menu_cnf => 1,
		menu_grp => '',
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	$::project_obj->read_hinshi_setting;
	
	gui_errormsg->open(
		msg  => '�ʻ�������ѹ���ȿ�Ǥ���ˤϡʺ��١���������¹Ԥ��Ʋ�������',
		type => 'msg',
		icon => 'info',
	);
}
1;
