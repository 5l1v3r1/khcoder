# �֥ġ���� -> �֥����ǥ��󥰡ץ�˥塼�ʲ��Υ��ޥ�ɤΤ���Υ��å���

package kh_cod::func;
use base qw(kh_cod);
use strict;

use mysql_getheader;
use Jcode;

#-----------------------------------------#
#   �����ǥ��󥰷�̤ν��ϡ�����ĹCSV��   #

sub cod_out_var{
	my $self    = shift;
	my $tani    = shift;
	my $outfile = shift;
	
	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }
	$self->cumulate if @{$self->{valid_codes}} > 30;
	
	# ������SQL������ܤκ���
	my ($sql,$head);
	my $flag = 0;
	my $hnum = 0;
	foreach my $i ('bun','dan','h5','h4','h3','h2','h1'){
		if ($i eq $self->tani){
			$flag = 1;
		}
		if ($flag){
			$sql = "$i"."_id,"."$sql";
			$head = "$i,"."$head";
			++$hnum;
		}
	}
	$head .= '������';
	$sql = "SELECT "."$sql";
	
	my @codename;                                 # �����ǥ�����̾������å�
	my $n = 0;
	foreach my $i (@{$self->valid_codes}){
		$sql .= "IF(".$i->res_table.".".$i->res_col.",1,0),";
		use kh_csv;
		$codename[$n] = $i->name;
		substr($codename[$n],0,2) = '';
		++$n;
	}
	chop $sql;
	$sql .= "\nFROM ".$self->tani."\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON ".$self->tani.".id = $i.id\n";
	}
	$sql .= "ORDER BY ".$self->tani.".id";
	
	# ���ϳ���
	open(CODO,">$outfile") or
		gui_errormsg->open(
			type => 'file',
			thefile => $outfile
		);
	print CODO "$head\n";
	my $h = mysql_exec->select($sql,1)->hundle;
	
	while (my $i = $h->fetch){
		my $current;
		my $current_code;
		my $n = 0;
		foreach my $j (@{$i}){
			if ($n < $hnum){                     # ���־���
				$current .= "$j,";
			} else {                              # ������
				if ($j){
					my $cnum = $n - $hnum;
					$current_code .= "$codename[$cnum] ";
				}
			}
			++$n;
		}
		if ($current_code){
			chop $current_code if $current_code;
			$current_code = kh_csv->value_conv($current_code);
		}
		print CODO "$current$current_code\n";
	}
	close (CODO);
	
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_sjis($outfile);
	}
}

#------------------------------------#
#   �����ǥ��󥰷�̤ν��ϡ�SPSS��   #

sub cod_out_spss{
	my $self     = shift;
	my $tani     = shift;
	my $outfile  = shift;
	my $outfile2 = substr($outfile,0,length($outfile)-4).".dat";

	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }
	$self->cumulate if @{$self->{valid_codes}} > 30;
	
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
	$sql .= "ORDER BY ".$self->tani.".id";
	
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
	$spss .= "file handle trgt1 /name=\'";
	#if ($::config_obj->os eq 'win32'){
	#	$spss .= Jcode->new($outfile2,'sjis')->euc;
	#} else {
	#	$spss .= $outfile2;
	#}
	$spss .= $outfile2;
	$spss .= "\'\n";
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

sub out2r_selected{
	my $self     = shift;
	my $tani     = shift;
	my $selected = shift;

	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	unless ($self->code($tani)){
		print "could not perform coding\n";
		return 0;
	}
	unless ($self->valid_codes){
		print "no valid codes\n";
		return 0;
	}
	$self->cumulate if @{$self->{valid_codes}} > 30;

	# ���򤵤줿�����ɤ�ꥹ�ȥ��å�
	my %if_selected = ();
	foreach my $i (@{$selected}){
		$if_selected{$i} = 1;
	}
	my @codes = ();
	foreach my $i (@{$self->codes}){
		push @codes, $i if $if_selected{$i->name};
	}
	$selected = \@codes;

	# SQLʸ
	my %tables = ();
	foreach my $i (@{$selected}){
		unless ($i->res_table){
			print "no result table!\n";
			return 0;
		}
		++$tables{$i->res_table};
	}
	my $sql = "SELECT ";
	foreach my $i (@{$selected}){
		$sql .= "IF(".$i->res_table.".".$i->res_col.",1,0),";
	}
	chop $sql;
	$sql .= "\nFROM ".$self->tani."\n";
	foreach my $i (keys %tables){
		$sql .= "LEFT JOIN $i ON ".$self->tani.".id = $i.id\n";
	}
	$sql .= "ORDER BY ".$self->tani.".id";
	#print "$sql\n";
	
	# �ǡ������Ф�
	my $r_command = '';
	my $nrow = 0;
	my $h = mysql_exec->select($sql,1)->hundle;
	while (my $i = $h->fetch){
		my $current;
		foreach my $j (@{$i}){
			$r_command .= "$j,";
		}
		++$nrow;
	}
	chop $r_command;
	
	my $ncol = @{$selected};
	$r_command =
		"d <- matrix( c($r_command), ncol=$ncol, nrow=$nrow, byrow=TRUE)";
	#print "$r_command\n";
	
	return $r_command;
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
	$self->cumulate if @{$self->{valid_codes}} > 30;

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
	$sql .= "ORDER BY ".$self->tani.".id";
	
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
	
	my $debug = 0;
	print "1.\n" if $debug;
	
	# �����ǥ��󥰤ȥ����ǥ��󥰷�̤Υ����å�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }
	$self->cumulate if @{$self->{valid_codes}} > 30;
	print "2.\n" if $debug;

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
	$sql .= "ORDER BY ".$self->tani.".id";
	print "3. $outfile\n" if $debug;
	
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
	print "4.\n" if $debug;
	
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
		$self->cumulate if @{$self->{valid_codes}} > 30;
		
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
		kh_msg->get('no_codes'), # ��������̵��
		$total - $least1,
		sprintf("%.2f",( ($total - $least1) / $total ) * 100)."%"
	];
	push @{$result}, [
		kh_msg->get('n_docs'), # ��ʸ�����
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
	
	# �����ǥ��󥰤μ¹�
	$self->code($tani) or return 0;
	unless ($self->valid_codes){ return 0; }
	$self->cumulate if @{$self->{valid_codes}} > 30;
	
	# �����ѿ��Υ����å�
	my ($outvar_tbl,$outvar_clm);
	my $var_obj = mysql_outvar::a_var->new(undef,$var_id);
	if ( $var_obj->{tani} eq $tani){
		$outvar_tbl = $var_obj->{table};
		$outvar_clm = $var_obj->{column};
	} else {
		$outvar_tbl = 'ct_outvar_cross';
		$outvar_clm = 'value';
		mysql_exec->drop_table('ct_outvar_cross');
		mysql_exec->do("
			CREATE TABLE ct_outvar_cross (
				id int primary key not null,
				value varchar(255)
			) TYPE=HEAP
		",1);
		my $sql;
		$sql .= "INSERT INTO ct_outvar_cross\n";
		$sql .= "SELECT $tani.id, $var_obj->{table}.$var_obj->{column}\n";
		$sql .= "FROM $tani, $var_obj->{tani}, $var_obj->{table}\n";
		$sql .= "WHERE\n";
		$sql .= "	$var_obj->{tani}.id = $var_obj->{table}.id\n";
		foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
			$sql .= "	and $var_obj->{tani}.$i"."_id = $tani.$i"."_id\n";
			last if ($var_obj->{tani} eq $i);
		}
		$sql .= "ORDER BY $tani.id";
		#print "$sql\n\n";
		mysql_exec->do("$sql",1);
	}
	
	
	# ������SQLʸ�κ���
	my $sql;
	$sql .= "SELECT $outvar_tbl.$outvar_clm, ";
	foreach my $i (@{$self->{valid_codes}}){
		$sql .= "sum( IF(".$i->res_table.".".$i->res_col.",1,0) ),";
	}
	$sql .= " count(*) \n";
	$sql .= "FROM $outvar_tbl\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON $outvar_tbl.id = $i.id\n";
	}
	$sql .= "\nGROUP BY $outvar_tbl.$outvar_clm";
	$sql .= "\nORDER BY $outvar_tbl.$outvar_clm";
	#print "$sql\n";
	
	my $h = mysql_exec->select($sql,1)->hundle;
	
	# ��̽��Ϥκ���
	my @result;
	my @for_chisq;
	
	# �����
	my @head = ('');
	foreach my $i (@{$self->{valid_codes}}){
		push @head, gui_window->gui_jchar($i->name);
	}
	push @head, kh_msg->get('n_cases');
	push @result, \@head;
	# ���
	my @sum = ( kh_msg->get('total') );
	my $total;
	while (my $i = $h->fetch){
		my $n = 0;
		my @current;
		my @current_for_chisq;
		my @c = @{$i};
		my $nd = pop @c;
		
		$var_obj->{labels}{$c[0]} = ''
			unless defined($var_obj->{labels}{$c[0]});
		
		next if
			   length($i->[0]) == 0
			or $c[0] eq '.'
			or $c[0] eq '��»��'
			or $c[0] =~  /^missing$/i
			or $var_obj->{labels}{$c[0]} eq '.'
			or $var_obj->{labels}{$c[0]} eq '��»��'
			or $var_obj->{labels}{$c[0]} =~ /^missing$/i
		;
		
		foreach my $h (@c){
			if ($n == 0){                         # �ԥإå���1���ܡ�
				if ( length($var_obj->{labels}{$h}) ){
					push @current, (
						gui_window->gui_jchar($var_obj->{labels}{$h})
					);
				} else {
					push @current, gui_window->gui_jchar($h,'euc');
				}
			} else {                              # ���
				$sum[$n] += $h;
				my $p = sprintf("%.2f",($h / $nd ) * 100);
				push @current_for_chisq, [$h, $nd - $h];
				if ($cell == 0){
					my $pp = "($p"."%)";
					$pp = '  '.$pp if length($pp) == 7;
					push @current, "$h $pp";
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
		push @for_chisq, \@current_for_chisq if @current_for_chisq;
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
				my $pp = "($p"."%)";
				$pp = '  '.$pp if length($pp) == 7;
				push @current, "$i $pp";
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

	# chi-square test
	my @chisq = &_chisq_test(\@current, \@for_chisq);
	push @result, \@chisq if @chisq;
	
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
	$self->cumulate if @{$self->{valid_codes}} > 29;
	
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
	my @for_chisq;

	# �����
	my @head = ('');
	foreach my $i (@{$self->{valid_codes}}){
		push @head, gui_window->gui_jchar($i->name,'euc');
	}
	push @head, kh_msg->get('n_cases'); # ��������
	push @result, \@head;

	# ���
	my @sum = (kh_msg->get('total')); # ���
	my $total;
	while (my $i = $h->fetch){
		my $n = 0;
		my @current;
		my @current_for_chisq;
		my @c = @{$i};
		my $nd = pop @c;
		unless ( length($i->[0]) ){next;}
		foreach my $h (@c){
			if ($n == 0){                         # �ԥإå�
				if (index($tani2,'h') == 0){
					push @current, gui_window->gui_jchar(mysql_getheader->get($tani2, $h),'cp932'); # Decoding
				} else {
					push @current, $h;
				}
			} else {                              # ���
				$sum[$n] += $h;
				my $p = sprintf("%.2f",($h / $nd ) * 100);
				push @current_for_chisq, [$h, $nd - $h];
				if ($cell == 0){
					my $pp = "($p"."%)";
					$pp = '  '.$pp if length($pp) == 7;
					push @current, "$h $pp";
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
		push @for_chisq, \@current_for_chisq if @current_for_chisq;
	}
	# ��׹�
	my @c = @sum;
	my @current;
	$n = 0;
	foreach my $i (@sum){
		if ($n == 0){
			push @current, $i;
		} else {
			my $p = sprintf("%.2f", ($i / $total) * 100);
			if ($cell == 0){
				my $pp = "($p"."%)";
				$pp = '  '.$pp if length($pp) == 7;
				push @current, "$i $pp";
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

	# chi-square test
	my @chisq = &_chisq_test(\@current, \@for_chisq);
	push @result, \@chisq if @chisq;

	return \@result;
}


sub _chisq_test{
	my @current   = @{$_[0]};
	my @for_chisq = @{$_[1]};
	my @chisq = ();
	
	my $R_debug = 0;
	if ($::config_obj->R){
		@chisq = ( kh_msg->get('chisq') ); # ����2����
		my $n = @current - 2;
		$::config_obj->R->lock;
		for (my $c = 0; $c < $n; ++$c){
			my $cmd = 'chi <- chisq.test(matrix( c(';
			my $nrow = 0;
			foreach my $i (@for_chisq){
				$cmd .= "$i->[$c][0],";
				$cmd .= "$i->[$c][1], ";
				++$nrow;
			}
			chop $cmd; chop $cmd;
			$cmd .= 
				"), nrow=$nrow, ncol=2, byrow=TRUE), correct=TRUE)\n"
				.'print ( paste( "khc:", chi$statistic, ":khcend", sep= "") )';
			print "send: $cmd ..." if $R_debug;
			$::config_obj->R->send($cmd);
			print "ok\n" if $R_debug;
			my $ret = $::config_obj->R->read(3);
			print "read: $ret\n" if $R_debug;
			if ( $ret =~ /khc:(.+):khcend/ ){
				$ret = $1;
			} else {
				warn "Could not read the output of R.\n$ret\n";
				push @chisq, '---';
				next;
			}

			my $ret_mod = $ret;
			$ret_mod =~ s/\x0D\x0A|\x0D|\x0A/\n/g;
			$ret_mod =~ s/ //g;
			$ret_mod = sprintf("%.3f", $ret_mod);
			if ( $ret =~ /na/i ){
				push @chisq, $ret;
				next;
			}

			if ($ret_mod > 0){
				print 'send: print (chi$p.value) ...' if $R_debug;
				$::config_obj->R->send(
					'print ( paste( "khc:", chi$p.value, ":khcend", sep="" ))'
				);
				print "ok\n" if $R_debug;
				my $p = $::config_obj->R->read(3);
				print "read: $p\n" if $R_debug;
				
				if ($p =~ /khc:(.+):khcend/){
					$p = $1;
				} else {
					warn "Could not read the output of R.\n$p\n";
					push @chisq, '---';
					next;
				}
				
				#substr($p, 0, 4) = '';
				#if ($p =~ /^(.+)\n\[[0-9]+\]/){
				#	$p = $1;
				#}
				if ($p < 0.01){
					$ret_mod .= '**';
				}
				elsif ($p < 0.05){
					$ret_mod .= '*';
				}
			}
			push @chisq, $ret_mod;
		}
		$::config_obj->R->unlock;
		push @chisq, ' ';
	}

	return @chisq;
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