package sample_hello_world1_scr;   # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                        # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	my $conf= {
		name     => '����ץ롧Hello World�ʲ��̡�', # ��˥塼��ɽ�������̾��
		menu_cnf => 0,                               # ��˥塼������
			# 0: ���ĤǤ�¹Բ�ǽ
			# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
			# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
	};
	return $conf;
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	# ���ޥ�ɥץ��ץȤ�ɽ��
	print "Hello World!\n";
	
	# GUI�Ǥ�ɽ����Perl/Tk����ѡ�
	my $mw = $::main_gui->mw;           # KH Coder�Υᥤ�󡦥�����ɥ������

	$mw->messageBox(                    # Tk�Υ�å������ܥå�����ɽ��
		-icon    => 'info',
		-type    => 'OK',
		-title   => 'KH Coder',
		-message => gui_window->gui_jchar('Hello World! / ����ˤ���������'),
		                                # gui_window->gui_jchar('ʸ����')�ǡ�
		                                # ʸ�������ɤ�GUI�Ѥ��Ѵ�
	);

		# Perl/Tk�ˤĤ��Ƥϡ�������Υڡ��������ѻ��ͤˤʤ�
		# http://www.geocities.jp/m_hiroi/perl_tk/index.html

	return 1;
}

1;