package kh_project_io;

use strict;
use MySQL::Backup_kh;
use MIME::Base64;
use YAML qw(DumpFile LoadFile);
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

sub import{
	my $file_save   = shift;
	my $file_target = shift;

	# �ץ������Ȥ򳫤��Ƥ�����ϥ�����
	$::main_gui->close_all;
	undef $::project_obj;
	$::main_gui->menu->refresh;
	$::main_gui->inner->refresh;

	# ʬ���оݥե�����β���
	my $zip = Archive::Zip->new();
	unless ( $zip->read( $file_save ) == "AZ_OK" ) {
		return undef;
	}
	unless ( $zip->extractMember('target',$file_target) == "AZ__OK" ){
		return undef;
	}

	# �ץ������Ȥ���Ͽ
	my $info = &get_info($file_save);
	
	my $new = kh_project->new(
		target  => $file_target,
		comment => Jcode->new($info->{comment})->sjis,
		icode   => 0,
	) or return 0;
	kh_projects->read->add_new($new) or return 0;

	# MySQL�ǡ����١����ν����ʥ��ꥢ��
	print "db: ", $new->dbname, "\n";
	my $dbh = mysql_exec->connect_db($new->dbname);

	# MySQL�ǡ����١���������






}


sub get_info{
	my $file = shift;
	
	# ����
	my $zip = Archive::Zip->new();
	unless ( $zip->read( $file ) == "AZ_OK" ) {
		return undef;
	}
	my $file_temp_info = $::config_obj->file_temp;
	unless ( $zip->extractMember('info',$file_temp_info) == "AZ__OK" ){
		return undef;
	}

	# ���
	my %info = LoadFile($file_temp_info) or return undef;
	foreach my $i (keys %info){
		$info{$i} = decode_base64($info{$i})
	}
	unlink($file_temp_info);

	return \%info;
}




1;
