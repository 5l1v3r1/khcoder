package p1_sample3_exec_r;            # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                           # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		name     => 'R���ޥ�ɤμ¹�',               # ��˥塼��ɽ�������̾��
		menu_cnf => 0,                               # ��˥塼������(1)
			# 0: ���ĤǤ�¹Բ�ǽ
			# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
			# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
		menu_grp => '����ץ�',                      # ��˥塼������(2)
			# ��˥塼�򥰥롼�ײ����������ˤ��������Ԥ���
			# ɬ�פʤ����ϡ�'',�פޤ��ϡ�undef,�פȤ��Ƥ������ɤ���
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	my $mw = $::main_gui->mw;           # KH Coder�Υᥤ�󡦥�����ɥ�

	# R���Ȥ��뤫�ɤ�����ǧ
	unless ( $::config_obj->R ){
		$mw->messageBox(                # Tk�Υ�å������ܥå�����ɽ��
			-icon    => 'info',
			-type    => 'OK',
			-title   => 'KH Coder',
			-message => 'Cannot use R!',
		);
		return 0;
	}

	# R���ޥ�ɤμ¹� 1
	$::config_obj->R->send('
		print(
			paste(
				memory.size(),
				memory.size(max=T),
				memory.limit(),
				sep=", "
			) 
		)
	');
	
	# �¹Է�̤μ��� 1
	my $t = $::config_obj->R->read();
	
	# ��̤򾯤����� 1
	$t =~ s/.+"(.+)"/$1/;
	$t =~ s/, / \t/g;
	$t = "Memory consumption of R (MB):\n\ncurrent	max	limit\n".$t;

	# R���ޥ�ɤμ¹� 2
	$::config_obj->R->send('
		print( sessionInfo() )
	');

	# �¹Է�̤μ��� 2
	my $t2 = $::config_obj->R->read();
	$t .= "\n\nsessionInfo():\n\n$t2";

	# ����ɽ��
	$mw->messageBox(
		-icon    => 'info',
		-type    => 'OK',
		-title   => 'KH Coder',
		-message => $t,
	);
	
	return 1;
}


1;
