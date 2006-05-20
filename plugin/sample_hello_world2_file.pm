package sample_hello_world2_file;  # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                        # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	my $conf= {
		name     => '����ץ롧Hello World�ʥե������', # ��˥塼��ɽ�������
		                                                 #                 ̾��
		menu_cnf => 1,                                   # ��˥塼������
				# 0: ���ĤǤ�¹Բ�ǽ
				# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
				# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
	};
	return $conf;
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{

	#-----------------------------------#
	#   GUI�ǽ�����Υե�����̾�����   #

	my $mw = $::main_gui->mw;           # KH Coder�Υᥤ�󡦥�����ɥ������

	my $path = $mw->getSaveFile(        # Tk�Υե����������������
		-title            => gui_window->gui_jchar('��å���������¸'),
		-initialdir       => $::config_obj->cwd,
		-defaultextension => '.txt',
		-filetypes        => [
			[ gui_window->gui_jchar("�ƥ�����"),'.txt' ],
			["All files",'*']
		]
	);
		# gui_window->gui_jchar('ʸ����')�ǡ�ʸ�������ɤ�GUI�Ѥ��Ѵ�
		# $::config_obj->cwd�ǡ�KH Coder��¸�ߤ���ǥ��쥯�ȥ������

	return 0 unless length($path);

	#------------------------------#
	#   ���Ϥ����å����������   #

	my $msg = '';
	$msg .= 'ʬ���оݥե����롧';
	$msg .= $::project_obj->file_target;
	$msg .= "\n";
	$msg .= '��⡧';
	$msg .= $::project_obj->comment;
	$msg .= "\n";
	$msg .= '��������';

	if ( $::project_obj->status_morpho ){
		$msg .= '�¹ԺѤ�'
	} else {
		$msg .= '̤�¹�'
	}

	$msg .= "\n\n";
	$msg .= '��KH Coder�Υ���ץ롦�ץ饰����ˤ��ƥ��Ƚ���';

	#----------------------#
	#   �ե�����ؤν���   #

	open (SMPLOUT,">$path") or          # �ե�����򥪡��ץ�
		gui_errormsg->open(             # �����ץ��Ի��Υ��顼ɽ��
			type => 'file',
			thefile => $path
		);

	print SMPLOUT $msg;                 # �ե�����ؽ񤭽Ф�

	close (SMPLOUT);                    # �ե�����Υ�����

	#--------------------#
	#   ��ǧ���̤�ɽ��   #
	
	
	return 1;
}




1;