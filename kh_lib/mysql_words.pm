#------------------------------#
#   ñ��ط��Υ��֥롼����   #
#------------------------------#

package mysql_words;
use strict;
use mysql_exec;

#--------------#
#   ñ�측��   #

# Usage: mysql_word->search(
# 	query  => 'EUC����ʸ',
# 	method => 'AND/OR',
# 	kihone => 1/0             # ���ܷ��Ǹ������뤫�ɤ���
# 	katuyo => 1/0             # ���ѷ���ɽ�����뤫�ɤ���
# );

sub search{
	my $class = shift;
	my %args = @_;
	my $self = \%args;
	bless $self, $class;
	
	my $query = $args{query};
	$query =~ s/��/ /g;
	my @query = split / /, $query;
	
	my $result;
	
	if ($args{kihon}){        # KHC����и�(���ܷ�)�򸡺�
		my $sql;
		$sql = '
			SELECT
				genkei.name, hselection.name, genkei.num, genkei.id, hinshi.name
			FROM
				genkei, hselection, hinshi
			WHERE
				    genkei.khhinshi_id = hselection.khhinshi_id
				AND genkei.hinshi_id = hinshi.id
				AND hselection.ifuse = 1
				AND genkei.nouse = 0'."\n";
		$sql .= "\t\t\tAND (\n";
		foreach my $i (@query){
			unless ($i){ next; }
			my $word = $self->conv_query($i);
			$sql .= "\t\t\t\tgenkei.name LIKE $word";
			if ($args{method} eq 'AND'){
				$sql .= " AND\n";
			} else {
				$sql .= " OR\n";
			}
		}
		substr($sql,-4,3) = '';
		$sql .= "\t\t\t)\n\t\tORDER BY\n\t\t\tgenkei.num DESC, genkei.name";
		my $t = mysql_exec->select($sql,1);
		$result = $t->hundle->fetchall_arrayref;
		
		# �֤���¾���к�
		if (
			mysql_exec->select("
				SELECT ifuse FROM hselection WHERE name = \'����¾\'
			",1)->hundle->fetch->[0]
		){
			foreach my $i (@{$result}){
				if ($i->[1] eq '����¾'){
					$i->[0] = "$i->[0]($i->[4])";
				}
			}
		}
		
		if ( ! $args{katuyo} ){         # ���Ѹ�ʤ��ξ��
			foreach my $i (@{$result}){
				pop @{$i};
				pop @{$i};
			}
		} else {                        # ���Ѹ줢��ξ��
			my $result2;
			foreach my $i (@{$result}){
				my $hinshi = pop @{$i};
				my $id = pop @{$i};
				push @{$result2}, $i;
				
				if ( index("$hinshi",'̾��-') == 0 ){
					next;
				}
				
				my $r = mysql_exec->select("      # ���Ѹ��õ��
					SELECT hyoso.name, katuyo.name, hyoso.num
					FROM hyoso, katuyo
					WHERE
						    hyoso.katuyo_id = katuyo.id
						AND hyoso.genkei_id = $id
					ORDER BY hyoso.num DESC, katuyo.name
				",1)->hundle->fetchall_arrayref;
				
				foreach my $h (@{$r}){            # ���Ѹ���ɲ�
					if ( length($h->[1]) > 1 ){
						$h->[1] = '   '.$h->[1];
						unshift @{$h}, 'katuyo';
						push @{$result2}, $h;
					}
				}
			}
			$result = $result2
		}

	} else {                  # ��-��и� ����
		my $sql;
		$sql = '
			SELECT hyoso.name, hinshi.name, katuyo.name, hyoso.num
			FROM hyoso, genkei, hinshi, katuyo
			WHERE
				    hyoso.genkei_id = genkei.id
				AND genkei.hinshi_id = hinshi.id
				AND hyoso.katuyo_id = katuyo.id AND (
		';
		foreach my $i (@query){
			my $word = $self->conv_query($i);
			$sql .= "\t\t\t\thyoso.name LIKE $word";
			if ($args{method} eq 'AND'){
				$sql .= " AND\n";
			} else {
				$sql .= " OR\n";
			}
		}
		substr($sql,-4,3) = '';
		$sql .= ") \n ORDER BY hyoso.num DESC, hyoso.name";
		$result = mysql_exec->select($sql,1)->hundle->fetchall_arrayref;
	}

	return $result;
}
sub conv_query{
	my $self = shift;
	my $q = shift;
	$q =~ s/'/\\'/go;
	
	if ($self->{mode} eq 'p'){
		$q = '\'%'."$q".'%\'';
	}
	elsif ($self->{mode} eq 'c'){
		$q = "\'$q\'";
	}
	elsif ($self->{mode} eq 'k'){
		$q = '\'%'."$q\'";
	}
	elsif ($self->{mode} eq 'z'){
		$q = "\'$q".'%\'';
	}
	return $q;
}

#-------------------------#
#   CSV�����ꥹ�Ȥν���   #

sub csv_list{
	use kh_csv;
	my $class = shift;
	my $target = shift;
	
	
	my $list = &_make_list;
	
	open (LIST,">$target") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$target"
		);
	
	# 1����
	my $line = '';
	foreach my $i (@{$list}){
		$line .= kh_csv->value_conv($i->[0]).',,';
	}
	chop $line;
	print LIST "$line\n";
	# 2���ܰʹ�
	my $row = 0;
	while (1){
		my $line = '';
		my $check;
		foreach my $i (@{$list}){
			$i->[1][$row][1] = '' unless defined($i->[1][$row][1]);
			$i->[1][$row][0] = '' unless defined($i->[1][$row][0]);
			$line .=kh_csv->value_conv($i->[1][$row][0]).",$i->[1][$row][1],";
			$check += $i->[1][$row][1] if $i->[1][$row][1];
		}
		chop $line;
		unless ($check){
			last;
		}
		print LIST "$line\n";
		++$row;
	}
	close (LIST);
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_sjis($target);
	}
}

sub csv_list_150{
	use kh_csv;
	my $class = shift;
	my $target = shift;

	my $t = mysql_exec->select('
		SELECT
		  genkei.name   as W,
		  genkei.num    as TF
		FROM genkei, hselection
		WHERE
		      genkei.khhinshi_id = hselection.khhinshi_id
		  and hselection.name != "�����ư��"
		  and hselection.name != "̤�θ�"
		  and hselection.name != "����"
		  and hselection.name != "̾��B"
		  and hselection.name != "���ƻ�B"
		  and hselection.name != "ư��B"
		  and hselection.name != "����B"
		  and hselection.name != "��ư��"
		  and hselection.name != "����¾"
		  and hselection.name != "HTML����"
		  and hselection.ifuse = 1
		ORDER BY TF DESC, W
		LIMIT 150
	',1)->hundle;

	# �ꥹ�ȹ�¤����
	my @data = ();
	$data[0] = ['��и�','�и���','','��и�','�и���','','��и�','�и���'];
	my $row = 1;
	my $col = 1;
	while (my $i = $t->fetch){
		push @{$data[$row]}, $i->[0];
		push @{$data[$row]}, $i->[1];
		push @{$data[$row]}, '' if $col <= 2;
		++$row;
		if ($row >= 51){
			$row = 1;
			++$col;
		}
	}

	# �ꥹ�ȹ�¤��ƥ����Ȥ˽���
	open (LIST,">$target") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$target"
		);

	foreach my $i (@data){
		my $c = 0;
		foreach my $h (@{$i}){
			print LIST ',' if $c;
			print LIST kh_csv->value_conv($h);
			++$c;
		}
		print LIST "\n";
	}

	close (LIST);
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_sjis($target);
	}
}

#-----------------------#
#   �и���� �ٿ�ʬ��   #

sub freq_of_f{
	my $class = shift;
	my $tani = shift;

	my $h = mysql_exec->select("
		select num
		from genkei, hselection
		where
			genkei.khhinshi_id = hselection.khhinshi_id
			and genkei.nouse = 0
			and hselection.ifuse = 1
	",1)->hundle;

	my ($n, %freq, $sum, $sum_sq); 
	while (my $i = $h->fetch){
		++$freq{$i->[0]};
		++$n;
		$sum += $i->[0];
		$sum_sq += $i->[0] ** 2;
	}
	my $mean = sprintf("%.2f", $sum / $n);
	my $sd = sprintf("%.2f", sqrt( ($sum_sq - $sum ** 2 / $n) / ($n - 1)) );

	my @r1;
	push @r1, ['�ۤʤ��� (n)  ', $n];
	push @r1, ['ʿ�� �и����', $mean];
	push @r1, ['ɸ���к�', $sd];
	
	my (@r2, $cum); 
	foreach my $i (sort {$a <=> $b} keys %freq){
		$cum += $freq{$i};
		push @r2, [
			$i,
			$freq{$i},
			sprintf("%.2f",($freq{$i} / $n) * 100),
			$cum,
			sprintf("%.2f",($cum / $n) * 100)
		];
	}
	return(\@r1, \@r2);
}

#-------------------------#
#   �и�ʸ��� �ٿ�ʬ��   #

sub freq_of_df{
	my $class = shift;
	my $tani = shift;

	my $h = mysql_exec->select("
		select f
		from genkei, hselection, df_$tani
		where
			genkei.khhinshi_id = hselection.khhinshi_id
			and genkei.id = df_$tani.genkei_id
			and genkei.nouse = 0
			and hselection.ifuse = 1
	",1)->hundle;

	my ($n, %freq, $sum, $sum_sq); 
	while (my $i = $h->fetch){
		++$freq{$i->[0]};
		++$n;
		$sum += $i->[0];
		$sum_sq += $i->[0] ** 2;
	}
	my $mean = sprintf("%.2f", $sum / $n);
	my $sd = sprintf("%.2f", sqrt( ($sum_sq - $sum ** 2 / $n) / ($n - 1)) );

	my @r1;
	push @r1, ['�ۤʤ��� (n)  ', $n];
	push @r1, ['ʿ�� ʸ���', $mean];
	push @r1, ['ɸ���к�', $sd];
	
	my (@r2, $cum); 
	foreach my $i (sort {$a <=> $b} keys %freq){
		$cum += $freq{$i};
		push @r2, [
			$i,
			$freq{$i},
			sprintf("%.2f",($freq{$i} / $n) * 100),
			$cum,
			sprintf("%.2f",($cum / $n) * 100)
		];
	}
	return(\@r1, \@r2);
}

#----------------------#
#   ñ��ꥹ�Ȥκ���   #

# �ʻ�ꥹ�ȥ��å�
sub _make_hinshi_list{
	my @hinshi = ();
	my $sql = '
		SELECT hselection.name, hselection.khhinshi_id
		FROM genkei, hselection
		WHERE
			    genkei.khhinshi_id = hselection.khhinshi_id
			AND hselection.ifuse = 1
		GROUP BY hselection.khhinshi_id
		ORDER BY hselection.khhinshi_id
	';
	my $t = mysql_exec->select($sql,1);
	while (my $i = $t->hundle->fetch){
		push @hinshi, [ $i->[0], $i->[1] ];
	}
	return \@hinshi;
}

sub _make_list{

	my $temp = &_make_hinshi_list;
	unless (eval (@{$temp})){
		print "oh, well, I don't know...\n";
		return;
	}

	my @hinshi = @{$temp};
	# ñ��ꥹ�ȥ��å�
	my @result = ();
	foreach my $i (@hinshi){
		my $sql;
		if ($i->[0] eq '����¾'){
			$sql  = "
				SELECT concat(genkei.name,'(',hinshi.name,')'), genkei.num
				FROM genkei, hinshi
				WHERE
					genkei.hinshi_id = hinshi.id
					and khhinshi_id = $i->[1]
					and genkei.nouse = 0
				ORDER BY num DESC, genkei.name
			";
		} else {
			$sql  = "
				SELECT name, num FROM genkei
				WHERE
					khhinshi_id = $i->[1]
					and genkei.nouse = 0
				ORDER BY num DESC, name
			";
		}
		my $t = mysql_exec->select($sql,1);
		push @result, ["$i->[0]", $t->hundle->fetchall_arrayref];
	}
	return \@result;
}

#--------------------------#
#   ñ������֤��롼����   #
#--------------------------#

sub num_kinds{
	my $hinshi = &_make_hinshi_list;
	my $sql = '';
	$sql .= 'SELECT count(*) ';
	$sql .= 'FROM genkei ';
	$sql .= "WHERE genkei.nouse = 0 and (\n";
	my $n = 0;
	foreach my $i (@{$hinshi}){
		if ($n){
			$sql .= '    or ';
		} else {
			$sql .= '       ';
		}
		$sql .= "khhinshi_id=$i->[1]\n";
		++$n;
	}
	$sql .= " )";
	return mysql_exec->select($sql,1)->hundle->fetch->[0];
}
sub num_kinds_all{
	return mysql_exec                   # HTML�����ͩ������ñ���������֤�
		->select("
			select count(*)
			from genkei
			where
				khhinshi_id!=99999 and genkei.nouse=0
		",1)->hundle->fetch->[0];
}
sub num_all{
	return mysql_exec                   # HTML�����ͩ������ñ������֤�
		->select("
			select sum(num)
			from genkei
			where 
				khhinshi_id!=99999 and genkei.nouse=0
		",1)->hundle->fetch->[0];
}

sub num_kotonari_ritsu{
	my $total = mysql_exec->select("
		select sum(num)
		from genkei
		where 
			khhinshi_id!=99999 and genkei.nouse=0
	",1)->hundle->fetch->[0];
	
	my $koto = mysql_exec->select("
		select count(*)
		from genkei
		where
			khhinshi_id!=99999 and genkei.nouse=0
	",1)->hundle->fetch->[0];
	
	unless ($total){return 0;}
	
	return sprintf("%.2f",($koto / $total) * 100)."%";
}

1;
