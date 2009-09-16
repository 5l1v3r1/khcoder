package p3_unidic_hukugo1_ch;  # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                    # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		                                             # ��˥塼��ɽ�������̾��
		name     => '��䥤ˤ��Ϣ��',
		menu_cnf => 2,                               # ��˥塼������(1)
			# 0: ���ĤǤ�¹Բ�ǽ
			# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
			# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
		menu_grp => 'ʣ���θ��С�UniDic��',        # ��˥塼������(2)
			# ��˥塼�򥰥롼�ײ����������ˤ��������Ԥ���
			# ɬ�פʤ����ϡ�'',�פޤ��ϡ�undef,�פȤ��Ƥ������ɤ���
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	my $self = shift;
	my $mw = $::main_gui->{win_obj};

	my $if_exec = 1;
	if (
		   ( -e $::project_obj->file_HukugoList )
		&& ( mysql_exec->table_exists('hukugo') )
	){
		my $t0 = (stat $::project_obj->file_target)[9];
		my $t1 = (stat $::project_obj->file_HukugoList)[9];
		#print "$t0\n$t1\n";
		if ($t0 < $t1){
			$if_exec = 0; # ���ξ��������Ϥ��ʤ�
		}
	}

	if ($if_exec){
		my $ans = $mw->messageBox(
			-message => gui_window->gui_jchar
				(
				   "���֤Τ����������¹Ԥ��褦�Ȥ��Ƥ��ޤ���"
				   ."������������û���֤ǽ�λ���ޤ���\n".
				   "³�Ԥ��Ƥ�����Ǥ�����"
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }

		my $w = gui_wait->start;

		my $t = '';
		$t .= '(Ϣ���ʻ�'."\n";
		$t .= "\t".'((ʣ��̾��)'."\n";
		$t .= "\t\t".'(̾��)'."\n";
		$t .= "\t\t".'(��Ƭ��)'."\n";
		$t .= "\t\t".'(������ ̾��Ū)'."\n";
		$t .= "\t\t".'(���� ����)'."\n";
		$t .= "\t\t".'(������� ����)'."\n";
		$t .= "\t".')'."\n";
		$t .= ')'."\n";
		$::config_obj->hukugo_chasenrc($t);
		
		use mysql_hukugo;
		mysql_hukugo->run_from_morpho;
		
		$::config_obj->hukugo_chasenrc('');
		
		print Jcode->new( $::config_obj->hukugo_chasenrc )->sjis;
		
		$w->end;
	}

	gui_window::hukugo->open;


	return 1;
}

1;
