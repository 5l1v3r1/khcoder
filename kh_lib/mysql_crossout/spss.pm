package mysql_crossout::spss;
use base qw(mysql_crossout);
use strict;

sub finish{
	my $self = shift;
	
	# �ե�����̾�η���
	my $file_data = substr($self->{file},0,length($self->{file})-4).".dat";
	my $file_la =substr($self->{file},0,length($self->{file})-4)."_Conv.sps";

	# �ǡ����ɤ߹����ѥ��󥿥å���

	my $spss;
	$spss .= "file handle trgt1 /name=\'";
	if ($::config_obj->os eq 'win32'){
		$spss .= Jcode->new($file_data,'sjis')->euc;
	} else {
		$spss .= $file_data;
	}
	$spss .= "\'\n";
	$spss .= "                 /lrecl=32767 .\n";
	$spss .= "data list list(',') file=trgt1 /\n";
	my @head;
	foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
		push @head, $i;
		$spss .= "  $i(f10.0)\n";
		if ($self->{tani} eq $i){
			last;
		}
	}
	$spss .= "  id(f10.0)\n";
	if ($self->{midashi}){
		$spss .= "  name(a255)\n";
	}
	$spss .= "  length_c(f10.0)\n";
	$spss .= "  length_w(f10.0)\n";
	my $wn = 0;
	foreach my $i (@{$self->{wList}}){
		$spss .= "  w$wn(f10.0)\n";
		++$wn;
	}
	$spss .= ".\nExecute.\n\n";

	$spss .= "variable labels\n";
	$wn = 0;
	foreach my $i (@{$self->{wList}}){
		$spss .= "  w$wn \'$self->{wName}{$i}\'\n";
		++$wn;
	}
	$spss .= ".\n";
	$spss .= "Execute.\n";

	open (SOUT,">$self->{file}") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$self->{file}",
		);
	print SOUT $spss;
	close (SOUT);
	kh_jchar->to_sjis($self->{file});

	# �ǡ����ե���������ʰ��־���ȤΥޡ�����

	open (OUTF,">$file_data") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => $self->{file},
		);
	
	my $sql;
	$sql .= "SELECT ";
	foreach my $i (@head){
		$sql .= "$i"."_id,";
	}
	chop $sql;
	$sql .= "\nFROM $self->{tani}\n";
	$sql .= "ORDER BY id";
	my $sth = mysql_exec->select($sql,1)->hundle;
	
	my $nc = 0;
	open (F,"$self->{file_temp}") or die;
	while (<F>){
		my $srow = $sth->fetchrow_hashref;
		my $head;
		foreach my $i (@head){
			$head .= $srow->{"$i"."_id"};
			$head .= ',';
		}
		print OUTF "$head"."$_";
		++$nc;
	}
	close (F);
	close (OUTF);
	unlink("$self->{file_temp}");

	# �ǡ����ѷ��ѥ��󥿥å���
	$spss = '';
	
	$spss .= "MATCH FILES FILE=* /DROP id length_w length_c";
	foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
		$spss .= " $i";
		if ($self->{tani} eq $i){
			last;
		}
	}
	$spss .= " name" if $self->{tani} =~ /h[1-5]/i;
	$spss .= ".\n";
	
	$spss .= "FLIP.\n";
	$spss .= "STRING ñ�� (A255) .\n";
	$wn = 0;
	foreach my $i (@{$self->{wList}}){
		$spss .= "if case_lbl = 'W$wn' ñ�� = '$self->{wName}{$i}'.\n";
		$spss .= "if case_lbl = 'w$wn' ñ�� = '$self->{wName}{$i}'.\n";
		++$wn;
	}
	$spss .= "STRING �ʻ� (A10) .\n";
	$wn = 0;
	foreach my $i (@{$self->{wList}}){
		$spss .= "if case_lbl = 'W$wn' �ʻ� = '$self->{hName}{$self->{wHinshi}{$i}}'.\n";
		$spss .= "if case_lbl = 'w$wn' �ʻ� = '$self->{hName}{$self->{wHinshi}{$i}}'.\n";
		++$wn;
	}

	if ($nc < 10){
		$nc = '00'.$nc;
	}
	elsif ($nc < 100){
		$nc = '0'.$nc;
	}
	$spss .= "MATCH FILES FILE=* /KEEP case_lbl ñ�� �ʻ� var001 to var$nc.\n";
	$spss .= "FORMATS var001 to var$nc (f8.0).\n";
	$spss .= "EXECUTE.\n";
	open (SOUT,">$file_la") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$file_la",
		);
	print SOUT $spss;
	close (SOUT);
	kh_jchar->to_sjis($file_la);


}



1;