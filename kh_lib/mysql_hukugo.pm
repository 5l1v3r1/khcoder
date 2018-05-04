# ʣ��̾��Υꥹ�Ȥ�������뤿��Υ��å�

package mysql_hukugo;

use strict;
use Benchmark;

use kh_jchar;
use mysql_exec;
use gui_errormsg;

sub search{
	my $class = shift;
	my %args = @_;
	
	if (length($args{query}) == 0){
		my @r = @{&get_majority()};
		return \@r;
	}
	
	$args{query} = Jcode->new($args{query},'sjis')->euc;
	$args{query} =~ s/��/ /g;
	my @query = split(/ /, $args{query});
	
	
	my $sql = '';
	$sql .= "SELECT name, num\n";
	$sql .= "FROM   hukugo\n";
	$sql .= "WHERE\n";
	
	my $num = 0;
	foreach my $i (@query){
		next unless length($i);
		
		if ($num){
			$sql .= "\t$args{method} ";
		}
		
		if ($args{mode} eq 'p'){
			$sql .= "\tname LIKE ".'"%'.$i.'%"';
		}
		elsif ($args{mode} eq 'c'){
			$sql .= "\tname LIKE ".'"'.$i.'"';
		}
		elsif ($args{mode} eq 'z'){
			$sql .= "\tname LIKE ".'"'.$i.'%"';
		}
		elsif ($args{mode} eq 'k'){
			$sql .= "\tname LIKE ".'"%'.$i.'"';
		}
		else {
			die('illegal parameter!');
		}
		$sql .= "\n";
		++$num;
	}
	$sql .= "ORDER BY num DESC, name\n";
	$sql .= "LIMIT 500\n";
	#print Jcode->new($sql)->sjis, "\n";
	
	my $h = mysql_exec->select($sql,1)->hundle;
	my @r = ();
	while (my $i = $h->fetch){
		push @r, [$i->[0], $i->[1]];
	}
	return \@r;
}

# ����ʸ���󤬻��ꤵ��ʤ��ä����
sub get_majority{
	my $h = mysql_exec->select("
		SELECT name, num
		FROM hukugo
		ORDER BY num DESC, name
		LIMIT 500
	",1)->hundle;
	
	my @r = ();
	while (my $i = $h->fetch){
		push @r, [$i->[0], $i->[1]];
	}
	return \@r;
}

sub run_from_morpho{
	my $class = shift;
	my $target = $::project_obj->file_HukugoList;

	my $t0 = new Benchmark;

	# �����ǲ���
	#print "1. morpho\n";
	
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
	kh_jchar->to_sjis($dist) if $::config_obj->os eq 'win32';
	
	$::config_obj->use_hukugo(1);
	$::config_obj->save;
	kh_morpho->run;
	$::config_obj->use_hukugo(0);
	$::config_obj->save;
	
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_euc($::project_obj->file_MorphoOut);
			my $ta2 = new Benchmark;
	}
	
	# �ɤ߹���
	#print "2. read\n";
	mysql_exec->drop_table("rowdata_h");
	mysql_exec->do("create table rowdata_h
		(
			hyoso varchar(255) not null,
			yomi varchar(255) not null,
			genkei varchar(255) not null,
			hinshi varchar(255) not null,
			katuyogata varchar(255) not null,
			katuyo varchar(255) not null,
			id int auto_increment primary key not null
		)
	",1);
	my $thefile = "'".$::project_obj->file_MorphoOut."'";
	$thefile =~ tr/\\/\//;
	mysql_exec->do("LOAD DATA LOCAL INFILE $thefile INTO TABLE rowdata_h",1);
	
	# ��֥ơ��֥����
	mysql_exec->drop_table("rowdata_h2");
	mysql_exec->do("
		create table rowdata_h2 (
			genkei varchar(255) not null
		)
	",1);
	mysql_exec->do("
		insert into rowdata_h2
		select genkei
		from rowdata_h
		where
			    hinshi = \'ʣ��̾��\'
	",1);
	
	# �񤭽Ф�
	#print "4. print out\n";
	mysql_exec->drop_table("hukugo");
	mysql_exec->do("
		CREATE TABLE hukugo (
			name varchar(255),
			num int
		)
	",1);
	open (F,">$target") or
		gui_errormsg->open(
			type => 'file',
			thefile => $target
		);
	print F "ʣ���,�и���\n";
	
	my $oh = mysql_exec->select("
		SELECT genkei, count(*) as hoge
		FROM rowdata_h2
		GROUP BY genkei
		ORDER BY hoge DESC
	",1)->hundle;
	
	use kh_csv;
	while (my $i = $oh->fetch){
		#print ".";
		my $tmp = Jcode->new($i->[0], 'euc')->tr('��-��','0-9'); 
		next if $tmp =~ /^(����)*(ʿ��)*(\d+ǯ)*(\d+��)*(\d+��)*(����)*(���)*(\d+��)*(\d+ʬ)*(\d+��)*$/o;   # ���ա�����
		next if $tmp =~ /^\d+$/o;    # ���ͤΤ�
		#print ",";
		print F kh_csv->value_conv($i->[0]).",$i->[1]\n";
		mysql_exec->do("
			INSERT INTO hukugo (name, num) VALUES (\"$i->[0]\", $i->[1])
		",1);
		#print "!";
	}
	close (F);
	
	kh_jchar->to_sjis($target) if $::config_obj->os eq 'win32';
	
	my $t1 = new Benchmark;
	#print timestr(timediff($t1,$t0)),"\n";
}


1;