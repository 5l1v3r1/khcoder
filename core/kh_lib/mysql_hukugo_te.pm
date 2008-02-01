# ʣ��̾��Υꥹ�Ȥ�������뤿��Υ��å�

package mysql_hukugo_te;

use strict;
use Benchmark;

use kh_jchar;
use mysql_exec;
use gui_errormsg;

sub run_from_morpho{
	my $class = shift;
	#my $target = shift;

	# �����ǲ���
	
	my $source = $::project_obj->file_target;
	my $dist   = $::project_obj->file_m_target;
	unlink($dist);
	my $icode = kh_jchar->check_code($source);
	open (MARKED,">$dist") or 
		gui_errormsg->open(
			type => 'file',
			thefile => $dist
		);
	open (SOURCE,"$source") or
		gui_errormsg->open(
			type => 'file',
			thefile => $source
		);
	while (<SOURCE>){
		chomp;
		my $text = Jcode->new($_,$icode)->h2z->euc;
		$text =~ s/ /��/go;
		print MARKED "$text\n";
	}
	close (SOURCE);
	close (MARKED);
	kh_jchar->to_sjis($dist) if $::config_obj->os eq 'win32';
	
	kh_morpho->run;

	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_euc($::project_obj->file_MorphoOut);
			my $ta2 = new Benchmark;
	}

	# �ե��륿����Ѥ�ñ̾��Υꥹ�Ȥ����
	my %is_alone = ();
	open (CHASEN,$::project_obj->file_MorphoOut) or 
			gui_errormsg->open(
				type    => 'file',
				thefile => $::project_obj->file_MorphoOut
			);
	while (<CHASEN>){
		$is_alone{(split /\t/, $_)[0]} = 1;
	}
	close (CHASEN);

	# TermExtract�μ¹�
	use TermExtract::Chasen;
	my $te_obj = new TermExtract::Chasen;
	my @noun_list = $te_obj->get_imp_word($::project_obj->file_MorphoOut);

	# ����
	my $target_csv = $::project_obj->file_HukugoListTE;
	open (OUT,">$target_csv") or
		gui_errormsg->open(
			type => 'file',
			thefile => $target_csv
		);;
	print OUT "�������,������\n";

	mysql_exec->drop_table("hukugo_te");
	mysql_exec->do("
		CREATE TABLE hukugo_te (
			name varchar(255),
			num double
		)
	",1);

	foreach (@noun_list) {
		next if $is_alone{$_->[0]};  # ñ̾��
		next if $_->[0] =~ /^(����)*(ʿ��)*(\d+ǯ)*(\d+��)*(\d+��)*(����)*(���)*(\d+��)*(\d+ʬ)*(\d+��)*$/; # ���ա�����
		my $tmp = Jcode->new($_->[0], 'euc')->tr('��-��','0-9'); # ���ͤΤ�
		next if $tmp =~ /^\d+$/;

		print OUT
			kh_csv->value_conv($_->[0]),
			",$_->[1]\n"
		;
		mysql_exec->do("
			INSERT INTO hukugo_te (name, num)
			VALUES (\"$_->[0]\", $_->[1])
		");
	}
	close (OUT);
	kh_jchar->to_sjis("$target_csv") if $::config_obj->os eq 'win32';
	
	return 1;
}


1;