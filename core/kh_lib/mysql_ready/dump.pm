package mysql_ready::dump;
use strict;

#----------------------------------------#
#   Ĺ������줬���ä����Υ���׽���   #
#----------------------------------------#

sub word_length{
	my $file = $::project_obj->file_datadir.'_dmp.txt';
	open (DMP,">$file") or
		gui_errormsg->open(
			type => 'file',
			thefile => $file
		);

	my $t = mysql_exec->select("
		SELECT genkei
		FROM   rowdata
		WHERE  
			( length(hyoso) = 255 ) or ( length(genkei) = 255 )
	",1)->hundle;
	while (my $i = $t->fetch){
		print DMP "$i->[0]\n";
	}

	close (DMP);

	my $msg = "���¤�Ķ����Ĺ���θ�ʷ����ǡˤ���䥤ˤ�ä���Ф���ޤ�����\n";
	$msg .= "KH Coder��������θ��Ĺ��������127ʸ���ޤǤǤ���\n\n";
	$msg .= "KH Coder�������θ��û�̤������֤�ǧ�����ޤ���\n";
	$msg .= "�����θ�ϰʲ��Υե�����˵�Ͽ���ޤ�����\n$file\n\n";
	$msg .= "OK�򥯥�å�����Ƚ�����³�Ԥ��ޤ���";
	gui_errormsg->open(
		msg  => "$msg",
		type => 'msg',
	);

	#exit;

	return 1;
}

1;
