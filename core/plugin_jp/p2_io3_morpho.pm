package p2_io3_morpho;
use strict;

#----------------------#
#   �ץ饰���������   #

sub plugin_config{
	return {
		name => '�����ǲ��Ϥη�̤���ɤ߹���',
		menu_cnf => 2,
		menu_grp => '������',
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	# �Хå����å�
	*backup_morpho = \&kh_morpho::run;
	*backup_jchar  = \&kh_jchar::to_euc;
	
	# �ѹ����Ƥ���
	*kh_morpho::run = \&dummy;
	*kh_jchar::to_euc = \&dummy;
	
	# �¹�
	$::main_gui->close_all;
	my $w = gui_wait->start;
	mysql_ready->first;
	$w->end;
	$::main_gui->menu->refresh;
	$::main_gui->inner->refresh;

	# �Хå����åפ����᤹
	*kh_morpho::run = \&backup_morpho;
	*kh_jchar::to_euc = \&backup_jchar;
	
	return 1;
}

sub dummy{
	return 1;
}


1;