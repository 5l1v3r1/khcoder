# �֥ġ���� -> �֥����ǥ��󥰡ץ�˥塼�ʲ��Υ��ޥ�ɤΤ���Υ��å���

package kh_cod::func;
use base qw(kh_cod);
use strict;

use mysql_getheader;
use Jcode;

#------------------------------------#
#   �����ǥ��󥰷�̤ν��ϡ�SPSS��   #

sub cod_out_spss{
	my $self     = shift;
	my $tani     = shift;
	my $outfile  = shift;
	my $outfile2 = "$outfile".".dat";

	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }

	my ($sql,@head);
	my $flag = 0;
	foreach my $i ('bun','dan','h5','h4','h3','h2','h1'){
		if ($i eq $self->tani){
			$flag = 1;
		}
		if ($flag){
			$sql = "$i"."_id,"."$sql";
			push @head, $i;
		}
	}
	@head = reverse @head;
	my %codes; my $cn = 1;
	$sql = "SELECT "."$sql";
	foreach my $i (@{$self->valid_codes}){
		$sql .= "IF(".$i->res_table.".".$i->res_col.",1,0),";
		push @head, "code$cn";
		$codes{"code$cn"} = Jcode->new($i->name)->sjis;
		++$cn;
	}
	chop $sql;

	$sql .= "\nFROM ".$self->tani."\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON ".$self->tani.".id = $i.id\n";
	}
	
	# �ǡ����ե�����
	open(CODO,">$outfile2") or
		gui_errormsg->open(
			type => 'file',
			thefile => $outfile2
		);
	
	my $h = mysql_exec->select($sql,1)->hundle;
	while (my $i = $h->fetch){
		my $current;
		foreach my $j (@{$i}){
			$current .= "$j,";
		}
		chop $current;
		print CODO "$current\n";
	}
	close (CODO);
	
	# ���󥿥å����ե�����
	my $spss;
	$spss .= "file handle trgt1 /name=\'$outfile2\'\n";
	$spss .= "                 /lrecl=32767 .\n";
	$spss .= "data list list(',') file=trgt1 /\n";
	foreach my $i (@head){
		$spss .= "  $i(f10.0)\n";
	}
	$spss .= ".\n";
	$spss .= ".variable labels\n";
	foreach my $i (keys %codes){
		$spss .= "  $i \'$codes{$i}\'\n";
	}
	$spss .= ".\n";
	$spss .= "execute.\n";
	
	open(CODO,">$outfile") or
		gui_errormsg->open(
			type => 'file',
			thefile => $outfile
		);
	print CODO "$spss";
	close (CODO);
}

#-----------------------------------#
#   �����ǥ��󥰷�̤ν��ϡ�CSV��   #

sub cod_out_csv{
	my $self    = shift;
	my $tani    = shift;
	my $outfile = shift;
	
	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }

	my ($sql,$head);
	my $flag = 0;
	foreach my $i ('bun','dan','h5','h4','h3','h2','h1'){
		if ($i eq $self->tani){
			$flag = 1;
		}
		if ($flag){
			$sql = "$i"."_id,"."$sql";
			$head = "$i,"."$head";
		}
	}
	$sql = "SELECT "."$sql";
	foreach my $i (@{$self->valid_codes}){
		$sql .= "IF(".$i->res_table.".".$i->res_col.",1,0),";
		use kh_csv;
		if ($::config_obj->os eq 'win32'){
			$head .= kh_csv->value_conv(Jcode->new($i->name)->sjis).",";
		} else {
			$head .= kh_csv->value_conv($i->name).",";
		}
	}
	chop $sql;
	chop $head;
	$sql .= "\nFROM ".$self->tani."\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON ".$self->tani.".id = $i.id\n";
	}
	
	open(CODO,">$outfile") or
		gui_errormsg->open(
			type => 'file',
			thefile => $outfile
		);
	print CODO "$head\n";
	
	my $h = mysql_exec->select($sql,1)->hundle;
	while (my $i = $h->fetch){
		my $current;
		foreach my $j (@{$i}){
			$current .= "$j,";
		}
		chop $current;
		print CODO "$current\n";
	}
	
	close (CODO);
}

#------------------------------------------#
#   �����ǥ��󥰷�̤ν��ϡʥ��ֶ��ڤ��   #

sub cod_out_tab{
	my $self    = shift;
	my $tani    = shift;
	my $outfile = shift;
	
	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }

	my ($sql,$head);
	my $flag = 0;
	foreach my $i ('bun','dan','h5','h4','h3','h2','h1'){
		if ($i eq $self->tani){
			$flag = 1;
		}
		if ($flag){
			$sql = "$i"."_id,"."$sql";
			$head = "$i\t"."$head";
		}
	}
	$sql = "SELECT "."$sql";
	foreach my $i (@{$self->valid_codes}){
		$sql .= "IF(".$i->res_table.".".$i->res_col.",1,0),";
		use kh_csv;
		if ($::config_obj->os eq 'win32'){
			$head .= kh_csv->value_conv_t(Jcode->new($i->name)->sjis)."\t";
		} else {
			$head .= kh_csv->value_conv_t($i->name)."\t";
		}
	}
	chop $sql;
	chop $head;
	$sql .= "\nFROM ".$self->tani."\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON ".$self->tani.".id = $i.id\n";
	}
	
	open(CODO,">$outfile") or
		gui_errormsg->open(
			type => 'file',
			thefile => $outfile
		);
	print CODO "$head\n";
	
	my $h = mysql_exec->select($sql,1)->hundle;
	while (my $i = $h->fetch){
		my $current;
		foreach my $j (@{$i}){
			$current .= "$j\t";
		}
		chop $current;
		print CODO "$current\n";
	}
	
	close (CODO);
}


#--------------#
#   ñ�㽸��   #

sub count{
	my $self = shift;
	my $tani = shift;
	
	use Benchmark;
	my $t0 = new Benchmark;
	
	$self->code($tani) or return 0;
	unless ($self->codes){ return 0; }
	
	# ��������
	my $total = mysql_exec->select("select count(*) from $tani",1)
		->hundle->fetch->[0];
	
	# �ƥ����ɤνи��������
	my $result;
	foreach my $i (@{$self->codes}){
		my $rows = 0;
		if ($i->res_table){                  # �и���0���н�
			$rows = mysql_exec->select(
				"SELECT sum(IF(".$i->res_col.",1,0)) FROM ".$i->res_table
			)->hundle;
			if ($rows = $rows->fetch){
				$rows = $rows->[0]; 
			} else {
				$rows = 0;
			}
		}
		
		push @{$result}, [
			$i->name,
			$rows,
			sprintf("%.2f",($rows / $total) * 100 )."%"
		];
	}
	
	# 1�ĤǤ⥳���ɤ�Ϳ����줿ʸ��ο������
	my $least1 = 0;
	if ($self->valid_codes){
		my $sql = "SELECT count(*)\nFROM $tani\n";
		foreach my $i (@{$self->tables}){
			$sql .= "LEFT JOIN $i ON $tani.id = $i.id\n";
		}
		$sql .= "WHERE\n";
		my $n = 0;
		foreach my $i (@{$self->valid_codes}){
			if ($n){ $sql .= "or "; }
			$sql .= $i->res_table.".".$i->res_col."\n";
			++$n;
		}
		$least1 = mysql_exec->select($sql,1)->hundle->fetch->[0];
	}
	
	push @{$result}, [
		'��������̵��',
		$total - $least1,
		sprintf("%.2f",( ($total - $least1) / $total ) * 100)."%"
	];
	push @{$result}, [
		'��ʸ�����',
		$total,
		''
	];
	
	my $t1 = new Benchmark;
	print timestr(timediff($t1,$t0)),"\n";
	
	return $result;
}

#----------------------------#
#   �����ѿ��ȤΥ�������   #

sub outtab{
	my $self  = shift;
	my $tani = shift;
	my $var_id = shift;
	my $cell  = shift;
	
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }
	
	my $result;
	my $var_obj = mysql_outvar::a_var->new(undef,$var_id);
	
	# ������SQLʸ�κ���
	my $sql;
	$sql .= "SELECT $var_obj->{table}.$var_obj->{column}, ";
	foreach my $i (@{$self->{valid_codes}}){
		$sql .= "sum( IF(".$i->res_table.".".$i->res_col.",1,0) ),";
	}
	$sql .= " count(*) \n";
	$sql .= "FROM $var_obj->{table}\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON $var_obj->{table}.id = $i.id\n";
	}
	$sql .= "\nGROUP BY $var_obj->{table}.$var_obj->{column}";
	$sql .= "\nORDER BY $var_obj->{table}.$var_obj->{column}";
	
	my $h = mysql_exec->select($sql,1)->hundle;
	
	# ��̽��Ϥκ���
	my @result;
	
	# �����
	my @head = ('');
	foreach my $i (@{$self->{valid_codes}}){
		push @head, Jcode->new($i->name)->sjis;
	}
	push @head, Jcode->new('��������')->sjis;
	push @result, \@head;
	# ���
	my @sum = (Jcode->new('���')->sjis);
	my $total;
	while (my $i = $h->fetch){
		my $n = 0;
		my @current;
		my @c = @{$i};
		my $nd = pop @c;
		unless ( length($i->[0]) ){next;}
		foreach my $h (@c){
			if ($n == 0){                         # �ԥإå�
				if ( length($var_obj->{labels}{$h}) ){
					push @current, Jcode->new($var_obj->{labels}{$h})->sjis;
				} else {
					push @current, $h;
				}
			} else {                              # ���
				$sum[$n] += $h;
				my $p = sprintf("%.2f",($h / $nd ) * 100);
				if ($cell == 0){
					push @current, "$h ($p"."%)";
				}
				elsif ($cell == 1){
					push @current, $h;
				} else {
					push @current, "$p"."%";
				}
			}
			++$n;
		}
		$total += $nd;
		push @current, $nd;
		push @result, \@current;
	}
	# ��׹�
	my @c = @sum;
	my @current; my $n = 0;
	foreach my $i (@sum){
		if ($n == 0){
			push @current, $i;
		} else {
			my $p = sprintf("%.2f", ($i / $total) * 100);
			if ($cell == 0){
				push @current, "$i ($p"."%)";
			}
			elsif ($cell == 1){
				push @current, $i;
			} else {
				push @current, "$p"."%";
			}
		}
		++$n;
	}
	push @current, $total;
	push @result, \@current;

	
	return \@result;
}

#----------------------------#
#   �ϡ��ᡦ����Ȥν���   #

sub tab{
	my $self  = shift;
	my $tani1 = shift;
	my $tani2 = shift;
	my $cell  = shift;
	
	$self->code($tani1) or return 0;
	unless ($self->valid_codes){ return 0; }

	my $result;

	# ������SQLʸ�κ���
	my $sql;
	$sql .= "SELECT $tani2.id, ";
	foreach my $i (@{$self->{valid_codes}}){
		$sql .= "sum( IF(".$i->res_table.".".$i->res_col.",1,0) ),";
	}
	$sql .= " count(*) \n";
	$sql .= "FROM $tani1\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON $tani1.id = $i.id\n";
	}
	$sql .= "LEFT JOIN $tani2 ON ";
	my ($flag1,$n);
	foreach my $i ("bun","dan","h5","h4","h3","h2","h1"){
		if ($tani2 eq $i){
			$flag1 = 1;
		}
		if ($flag1){
			if ($n){$sql .= " AND ";}
			$sql .= "$tani1.$i".'_id = '."$tani2.$i".'_id ';
			++$n;
		}
	}
	$sql .= "\n";
	$sql .= "\nGROUP BY ";
	my $flag2 = 0;
	foreach my $i ("bun","dan","h5","h4","h3","h2","h1"){
		if ($tani2 eq $i){
			$flag2 = 1;
		}
		if ($flag2){
			$sql .= "$tani1.$i".'_id,';
		}
	}
	chop $sql;
	$sql .= "\nORDER BY $tani2.id";
	
	my $h = mysql_exec->select($sql,1)->hundle;
	
	# ��̽��Ϥκ���
	my @result;
	
	# �����
	my @head = ('');
	foreach my $i (@{$self->{valid_codes}}){
		push @head, Jcode->new($i->name)->sjis;
	}
	push @head, Jcode->new('��������')->sjis;
	push @result, \@head;
	# ���
	my @sum = (Jcode->new('���')->sjis);
	my $total;
	while (my $i = $h->fetch){
		my $n = 0;
		my @current;
		my @c = @{$i};
		my $nd = pop @c;
		unless ( length($i->[0]) ){next;}
		foreach my $h (@c){
			if ($n == 0){                         # �ԥإå�
				if (index($tani2,'h') == 0){
					push @current, mysql_getheader->get($tani2, $h);
				} else {
					push @current, $h;
				}
			} else {                              # ���
				$sum[$n] += $h;
				my $p = sprintf("%.2f",($h / $nd ) * 100);
				if ($cell == 0){
					push @current, "$h ($p"."%)";
				}
				elsif ($cell == 1){
					push @current, $h;
				} else {
					push @current, "$p"."%";
				}
			}
			++$n;
		}
		$total += $nd;
		push @current, $nd;
		push @result, \@current;
	}
	# ��׹�
	my @c = @sum;
	my @current; my $n = 0;
	foreach my $i (@sum){
		if ($n == 0){
			push @current, $i;
		} else {
			my $p = sprintf("%.2f", ($i / $total) * 100);
			if ($cell == 0){
				push @current, "$i ($p"."%)";
			}
			elsif ($cell == 1){
				push @current, $i;
			} else {
				push @current, "$p"."%";
			}
		}
		++$n;
	}
	push @current, $total;
	push @result, \@current;

	
	return \@result;
}

#------------------------------#
#   ����å����ɤ������¬��   #
sub jaccard{
	my $self = shift;
	my $tani = shift;
	
	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }
	
	my ($n, @head) = (0, (''));
	foreach my $i (@{$self->valid_codes}){
		push @head, Jcode->new($i->name)->sjis;        # ���Ϸ�̡��إå���
		++$n;
	}
	unless ($n > 1){return 0;}
	
	# ��̽��Ϥκ���
	my @result;
	push @result, \@head;
	
	foreach my $i (@{$self->valid_codes}){           # ���Ϸ�̡���ع���
		my @current = (Jcode->new($i->name)->sjis);
		foreach my $h (@{$self->valid_codes}){
			if ($i->name eq $h->name){
				push @current,"1.000";
			} else {
				push @current, kh_cod::func->_jaccard($i,$h);
			}
		}
		push @result, \@current;
	}
	return \@result;
}


sub _jaccard{
	my $class = shift;
	my $c1    = shift;
	my $c2    = shift;
	
	my @tables;
	push @tables, $c1->res_table;
	unless ($c1->res_table eq $c2->res_table){
		push @tables, $c2->res_table;
	}

	# ξ���и����Ƥ��륱����
	my $sql1 = "SELECT * FROM ".$c1->tani."\n";
	foreach my $i (@tables){
		$sql1 .= "LEFT JOIN $i ON ".$c1->tani.".id = $i.id\n";
	}
	$sql1 .= "WHERE\n";
	$sql1 .= $c1->res_table.".".$c1->res_col." AND ".$c2->res_table.".".$c2->res_col;
	
	my $both =  mysql_exec->select($sql1,1)->hundle->rows;

	# �ɤ��餫���и����Ƥ��륱����
	my $sql2 = "SELECT * FROM ".$c1->tani."\n";
	foreach my $i (@tables){
		$sql2 .= "LEFT JOIN $i ON ".$c1->tani.".id = $i.id\n";
	}
	$sql2 .= "WHERE\n";
	$sql2 .= "IFNULL(".$c1->res_table.".".$c1->res_col.",0) OR IFNULL(".$c2->res_table.".".$c2->res_col.",0)";
	
	my $n = mysql_exec->select($sql2,1)->hundle->rows;
	
	unless ($n){return '0.000'; }
	return sprintf("%.3f",$both / $n);
}


1;