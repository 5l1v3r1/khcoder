package kh_project_io;
use strict;
use MySQL::Backup_kh;
use MIME::Base64;
use YAML::XS qw(DumpFile LoadFile);               # XS�Τޤޤ��ɤ���
use Archive::Zip;

sub export{
	my $savefile = $_[0];

	my $mb = new_from_DBH MySQL::Backup_kh($::project_obj->dbh);

	# MySQL�Υǡ������Ǽ
	my $file_temp_mysql = $::config_obj->file_temp;
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

	# ����ե���������
	my $file_temp_info = $::config_obj->file_temp;
	my %info;
	$info{'file_name'} = encode_base64($::project_obj->file_short_name,'');
	$info{'comment'}   = encode_base64($::project_obj->comment,'');
	DumpFile($file_temp_info, %info) or
		gui_errormsg->open(
			type => 'file',
			file => $file_temp_info
		)
	;

	# Zip�ե�����˸Ǥ��
	my $zip = Archive::Zip->new();
	
	$zip->addFile( $file_temp_mysql, 'mysql' );
	$zip->addFile( $file_temp_info,  'info' );
	$zip->addFile( $::project_obj->file_target, 'target');
	
	unless ( $zip->writeToFileNamed($savefile) == "AZ_OK" ) {
		gui_errormsg->open(
			type => 'file',
			file => $savefile
		)
	}

	# ����ե��������
	unlink ($file_temp_mysql, $file_temp_info);

	print "OK\n";
}



1;
