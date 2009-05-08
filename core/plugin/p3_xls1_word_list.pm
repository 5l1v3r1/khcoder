package p3_xls1_word_list;  # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		                                             # ��˥塼��ɽ�������̾��
		name     => '��и�ꥹ�ȡ��ʻ��̡��и�����硦xls��',
		menu_cnf => 2,                               # ��˥塼������(1)
			# 0: ���ĤǤ�¹Բ�ǽ
			# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
			# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
		menu_grp => '����Excel�б�',               # ��˥塼������(2)
			# ��˥塼�򥰥롼�ײ����������ˤ��������Ԥ���
			# ɬ�פʤ����ϡ�'',�פޤ��ϡ�undef,�פȤ��Ƥ������ɤ���
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{

	#----------------#
	#   ���Ϥν���   #

	use Spreadsheet::WriteExcel;
	use Unicode::String qw(utf8 utf16);

	my $f    = $::project_obj->file_TempExcel;
	my $workbook  = Spreadsheet::WriteExcel->new($f);
	my $worksheet = $workbook->add_worksheet(
		utf8( Jcode->new('������1')->utf8 )->utf16,
		1
	);

	my $font = '';
	if ($] > 5.008){
		$font = gui_window->gui_jchar('�ͣ� �Х����å�', 'euc');
	} else {
		$font = 'MS PGothic';
	}
	$workbook->{_formats}->[15]->set_properties(
		font       => $font,
		size       => 10,
		valign     => 'vcenter',
		align      => 'center',
	);
	my $format_n = $workbook->add_format(         # ����
		num_format => '0',
		size       => 10,
		font       => $font,
		align      => 'right',
	);
	my $format_c = $workbook->add_format(         # ʸ����
		font       => $font,
		size       => 10,
		align      => 'left',
		num_format => '@'
	);

	#----------#
	#   ����   #

	my $list = &mysql_words::_make_list;

	my $line = '';
	my $col = 0;
	foreach my $i (@{$list}){
		# �ʻ�̾
		$worksheet->write_unicode(
			0,
			$col,
			utf8( Jcode->new($i->[0],'euc')->utf8 )->utf16,
			$format_c
		);
		# �졦�и���
		my $row = 1;
		foreach my $h (@{$i->[1]}){
			$worksheet->write_unicode(
				$row,
				$col,
				utf8( Jcode->new($h->[0],'euc')->utf8 )->utf16,
				$format_c
			);
			$worksheet->write_number(
				$row,
				$col + 1,
				$h->[1],
				$format_n
			);
			++$row;
		}
		$col += 2;
	}

	$workbook->close;
	gui_OtherWin->open($f);

	return 1;
}

1;
