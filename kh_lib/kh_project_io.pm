package kh_project_io;
#use strict;
use MySQL::Backup_kh;

sub export{
	my $savefile = $_[0];

	my $mb = new_from_DBH MySQL::Backup_kh($::project_obj->dbh);

	# MySQL�Υǡ������Ǽ
	my $n = 0;
	my $file_temp_mysql = 'mysql.tmp'.$n;
	while (-e $file_temp_mysql){
		++$n;
		$file_temp_mysql = 'mysql.tmp'.$n;
	}

	open (MYSQLO,">$file_temp_mysql") or
		gui_errormsg->open(
			type => 'file',
			file => $file_temp_mysql
		)
	;
	print MYSQLO $mb->create_structure();
	print MYSQLO $mb->data_backup();
	close (MYSQLO);


	# MySQL::Backup�Ϥ�����Ƚ�������ɬ�פ�����

	# 1. �ե�����ϥ�ɥ���Ϥ��ơ������˽񤭹��ޤ�����ˤ��ʤ��ȥ��꤬�ѥ�
	# 2. ʣ��Index���б����Ƥ��ʤ�
	#    ��primary key�ʳ���index�ϡ��ǡ�����insert������˺�������褦��
	# 3. �ꥹ�ȥ�����Ȥ���ե��������Τ�쵤���ɤޤ���1�ԤŤĤ�




	print "OK\n";
}



1;
