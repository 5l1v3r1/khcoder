package kh_cod::func;
use base qw(kh_cod);
use strict;

use mysql_getheader;
use Jcode;

#-----------------------------------#
#   �����ǥ��󥰷�̤ν��ϡ�CSV��   #

sub cod_out_csv{
	my $self    = shift;
	my $outfile = shift;
	
	my $sql;
	
}




#--------------#
#   ñ�㽸��   #

sub count{
	my $self = shift;
	my $tani = shift;
	
	$self->code($tani) or return 0;
	
	# ��������
	my $total = mysql_exec->select("select count(*) from $tani",1)
		->hundle->fetch->[0];
	
	# �ƥ����ɤνи��������
	my $result;
	foreach my $i (@{$self->{codes}}){
		my $rows = 0;
		if ($i->{res_table}){                # �и���0���н�
			$rows = mysql_exec->select("SELECT count(*) FROM $i->{res_table}")
				->hundle;
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
	my $sql = "SELECT count(*)\nFROM $tani\n";
	foreach my $i (@{$self->{codes}}){
		unless ( $i->{res_table} ){next;} # �и���0���н�
		$sql .= "LEFT JOIN $i->{res_table} ON $tani.id = $i->{res_table}.id\n";
	}
	$sql .= "WHERE\n";
	my $n = 0;
	foreach my $i (@{$self->{codes}}){
		unless ( $i->{res_table} ){next;} # �и���0���н�
		if ($n){ $sql .= "or "; }
		$sql .= "$i->{res_table}.num\n";
		++$n;
	}
	my $least1 = mysql_exec->select($sql,1)->hundle->fetch->[0];
	
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
	
	return $result;
}

#----------------------------#
#   �ϡ��ᡦ����Ȥν���   #

sub tab{
	my $self  = shift;
	my $tani1 = shift;
	my $tani2 = shift;
	my $cell  = shift;
	
	$self->code($tani1) or return 0;

	my $result;

	# ������SQLʸ�κ���
	my $sql;
	$sql .= "SELECT $tani2.id, ";
	foreach my $i (@{$self->{codes}}){
		unless ( $i->{res_table} ){next;} # �и���0���н�
		$sql .= "sum( IF($i->{res_table}.num,1,0) ),";
	}
	$sql .= " count(*) \n";
	$sql .= "FROM $tani1\n";
	foreach my $i (@{$self->{codes}}){
		unless ( $i->{res_table} ){next;} # �и���0���н�
		$sql .= "LEFT JOIN $i->{res_table} ON $tani1.id = $i->{res_table}.id\n";
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
	foreach my $i (@{$self->{codes}}){
		unless ( $i->{res_table} ){next;} # �и���0���н�
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
	my ($n, @head) = (0, (''));
	foreach my $i (@{$self->{codes}}){
		unless ( $i->{res_table} ){next;}
		push @head, Jcode->new($i->name)->sjis;        # ���Ϸ�̡��إå���
		++$n;
	}
	unless ($n > 1){return 0;}
	
	# ��̽��Ϥκ���
	my @result;
	push @result, \@head;
	
	foreach my $i (@{$self->{codes}}){                 # ���Ϸ�̡���ع���
		unless ( $i->{res_table} ){next;}
		my @current = (Jcode->new($i->name)->sjis);
		foreach my $h (@{$self->{codes}}){
			unless ( $h->{res_table} ){next;}
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
	
	# ξ���и����Ƥ��륱����
	my $both = mysql_exec->select("
		SELECT *
		FROM $c1->{tani}
			LEFT JOIN $c1->{res_table} ON $c1->{tani}.id = $c1->{res_table}.id
			LEFT JOIN $c2->{res_table} ON $c1->{tani}.id = $c2->{res_table}.id
		WHERE
			$c1->{res_table}.num AND $c2->{res_table}.num
	",1)->hundle->rows;
	
	# �ɤ��餫���и����Ƥ��륱����
	my $n = mysql_exec->select("
		SELECT *
		FROM $c1->{tani}
			LEFT JOIN $c1->{res_table} ON $c1->{tani}.id = $c1->{res_table}.id
			LEFT JOIN $c2->{res_table} ON $c1->{tani}.id = $c2->{res_table}.id
		WHERE
			IFNULL($c1->{res_table}.num,0) OR IFNULL($c2->{res_table}.num,0)
	",1)->hundle->rows;
	
	return sprintf("%.3f",$both / $n);
}


1;