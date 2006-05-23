package sample_sql;                # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                        # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	my $conf= {
		name     => '����ץ� - SQLʸ�μ¹�',      # ��˥塼��ɽ�������̾��
		menu_cnf => 2,                            # ��˥塼������
				# 0: ���ĤǤ�¹Բ�ǽ
				# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
				# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
	};
	return $conf;
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{

	#-------------------------#
	#   �¹Ԥ���SQLʸ�����   #
	
	# �ѽи��̾���
	my $sql1 .= "
		SELECT genkei.name, genkei.num
		FROM genkei, khhinshi
		WHERE
		  genkei.khhinshi_id = khhinshi.id
		  AND khhinshi.name = '̾��'
		ORDER BY genkei.num DESC
		LIMIT 10
	";

	# �ѽФ����ʻ��KH Coder��
	my $sql2 = "
		SELECT khhinshi.name, count(*) as kotonari, sum(genkei.num) as sousu
		FROM khhinshi, genkei
		WHERE
		  genkei.khhinshi_id = khhinshi.id
		GROUP BY khhinshi.id
		ORDER BY kotonari DESC
		LIMIT 10
	";

	# �ѽФ����ʻ����䥡�
	my $sql3 = "
		SELECT hinshi.name, count(*) as kotonari, sum(genkei.num) as sousu
		FROM hinshi, genkei
		WHERE
		  genkei.hinshi_id = hinshi.id
		GROUP BY hinshi.id
		ORDER BY kotonari DESC
		LIMIT 10
	";

	#-----------------#
	#   SQLʸ�μ¹�   #

	my ($result1, $result2, $result3);

	my $h = mysql_exec->select($sql1)->hundle;
	while (my $i = $h->fetch){
		$result1 .= "\t$i->[0] ($i->[1])\n";
	}

	$h = mysql_exec->select($sql2)->hundle;
	while (my $i = $h->fetch){
		$result2 .= "\t$i->[0] ($i->[1], $i->[2])\n";
	}

	$h = mysql_exec->select($sql3)->hundle;
	while (my $i = $h->fetch){
		$result3 .= "\t$i->[0] ($i->[1], $i->[2])\n";
	}

		# $h = mysql_exec->select("SQLʸ")->hundle; �ǡ�SQLʸ��¹ԡ�
		# $i = $h->fetch; �ǡ���ԤŤķ�̤������


	#------------------------------#
	#   ɽ�������å����������   #

	chop $sql1; chop $sql1; substr($sql1,0,1) = '';
	chop $sql2; chop $sql2; substr($sql2,0,1) = '';
	chop $sql3; chop $sql3; substr($sql3,0,1) = '';

	my $msg;
	
	$msg .= "���ơ��֥�̾�������̾�ˤĤ��Ƥϡ��ޥ˥奢���4.1�������������\n\n";
	$msg .= "���ѽФ���̾��ȥå�10\n";
	$msg .= "��SQLʸ\n$sql1\n";
	$msg .= "����� / ���å���Ͻи���\n$result1\n";
	$msg .= "���ѽФ����ʻ�ȥå�10��KH Coder���ʻ�ʬ��ǡ��ۤʤ����ν��\n";
	$msg .= "��SQLʸ\n$sql2\n";
	$msg .= "����� / ���å���ϰۤʤ����ʼ�����ˤ���и���\n$result2\n";
	$msg .= "���ѽФ����ʻ�ȥå�10����䥤��ʻ�ʬ��ǡ��ۤʤ����ν��\n";
	$msg .= "��SQLʸ\n$sql3\n";
	$msg .= "����� / ���å���ϰۤʤ����ʼ�����ˤ���и���\n$result3\n";

	$msg =~ s/\t\t/\t/g;

	#--------------------#
	#   ��ǧ���̤�ɽ��   #

	gui_window::sample_sql->open(
		msg  => $msg
	);
	return 1;
}

#------------------------------#
#   ��ǧ����ɽ���ѤΥ롼����   #

package gui_window::sample_sql;               # �����ιԤϡ�gui_window::�פǻ�
use base qw(gui_window);                      #           �ޤ�Ŭ����̾�Τ��ѹ�
use strict;
use Tk;

## Window�κ���
sub _new{
	# �ѿ��μ���
	my $self = shift;
	my %args = @_;
	my $mw = $self->win_obj; # Window��Tk���֥������ȡˤ��������$mw�˳�Ǽ

	# Window�Υ����ȥ������
	$mw->title( gui_window->gui_jchar('�¹Ԥ���SQLʸ�Ȥ��η��') );

	# ��٥��ɽ��(0)
	$mw->Label(
		-text => gui_window->gui_jchar(' �ʲ���SQLʸ��¹Ԥ��ޤ�����'),
	)->pack(
		-anchor => 'w',
		-pady => 5
	);

	# �ƥ����ȥե�����ɡ�Read Only�ˤ�ɽ��
	my $text_widget = $mw->Scrolled(
		"ROText",
		-scrollbars => 'osoe',
		-height     => 20,
		-width      => 46,
	)->pack(
		-padx   => 2,
		-fill   => 'both',
		-expand => 'yes'
	);
	$text_widget->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$text_widget]);

	# �ƥ����ȥե�����ɤ˥�å�����������
	$text_widget->insert(
		'end',
		gui_window->gui_jchar( $args{msg} )
	);

	# ���Ĥ���ץܥ����ɽ��
	$mw->Button(
		-text    => gui_window->gui_jchar('�Ĥ���'),
		-command => sub{ $self->close; }
	)->pack(
		-pady => 2
	)->focus;

	return $self;
}

## Window��̾�Τ�����
sub win_name{                 
	return 'w_sample_sql';               # �����ιԤϡ�w_�פǻϤޤ�Ŭ����̾��
}	                                     #                             ���ѹ�

1;
