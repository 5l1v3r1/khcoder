package mysql_hukugo_te::ipadic;
use base qw(mysql_hukugo_te);

use strict;

my $debug = 0;

sub _run_from_morpho{
	#my $class = shift;
	#my $target = shift;

	# �����ǲ���
	my $t0 = new Benchmark;
	print "01. Marking...\n" if $debug;
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
		$text =~ s/\\/��/go;
		$text =~ s/'/��/go;
		$text =~ s/"/��/go;
		print MARKED "$text\n";
	}
	close (SOURCE);
	close (MARKED);
	
	print "02. Converting Codes...\n" if $debug;
	kh_jchar->to_sjis($dist) if $::config_obj->os eq 'win32';
	
	print "03. Chasen...\n" if $debug;
	kh_morpho->run;

	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_euc($::project_obj->file_MorphoOut);
	}

	# �ե��륿����Ѥ�ñ̾��Υꥹ�Ȥ����
	print "04. Making the Filter...\n" if $debug;
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
	print "05. TermExtract...\n" if $debug;
	my $te_obj = new TermExtract::Chasen;
	my @noun_list = $te_obj->get_imp_word($::project_obj->file_MorphoOut);

	# ����
	print "06. Output...\n" if $debug;
	my $data_out = 
		 kh_msg->get('gui_window::use_te_g->h_hukugo')
		.','
		.kh_msg->get('gui_window::use_te_g->h_score')
		."\n"
	;
	$data_out = Encode::encode('euc-jp',$data_out);


	mysql_exec->drop_table("hukugo_te");
	mysql_exec->do("
		CREATE TABLE hukugo_te (
			name varchar(255),
			num double
		)
	",1);

	foreach (@noun_list) {
		# ñ̾��Υ�������print���ƥ����å���
		#if ($is_alone{$_->[0]}){
		#	print Jcode->new("$_->[0], $_->[1]\n")->sjis
		#		if $_->[1] > 1;
		#}

		next if $is_alone{$_->[0]};  # ñ̾��
		
		my $tmp = Jcode->new($_->[0], 'euc')->tr('��-��','0-9'); 
		next if $tmp =~ /^(����)*(ʿ��)*(\d+ǯ)*(\d+��)*(\d+��)*(����)*(���)*(\d+��)*(\d+ʬ)*(\d+��)*$/o;   # ���ա�����
		next if $tmp =~ /^\d+$/o;    # ���ͤΤ�

		$data_out .= kh_csv->value_conv($_->[0]).",$_->[1]\n";
		mysql_exec->do("
			INSERT INTO hukugo_te (name, num)
			VALUES (\"$_->[0]\", $_->[1])
		");
	}

	$data_out = Jcode->new($data_out, 'euc')->sjis
		if $::config_obj->os eq 'win32';

	my $target_csv = $::project_obj->file_HukugoListTE;
	open (OUT,">$target_csv") or
		gui_errormsg->open(
			type => 'file',
			thefile => $target_csv
		);
	print OUT $data_out;
	close (OUT);
	
	my $t1 = new Benchmark;
	print timestr(timediff($t1,$t0)),"\n" if $debug;

	return 1;
}


1;