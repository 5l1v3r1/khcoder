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
	
	my $query = $args{query};
	$query =~ s/��/ /g;
	my @query = split / /, $query;
	
	my $result;
	
	if ($args{kihon}){        # KHC����и�(���ܷ�)�򸡺�
		my $sql;
		$sql = '
			SELECT
				genkei.name, hselection.name, genkei.num, genkei.id
			FROM
				genkei, hselection
			WHERE
				    genkei.khhinshi_id = hselection.khhinshi_id
				AND hselection.ifuse = 1'."\n";
		$sql .= "\t\t\tAND (\n";
		foreach my $i (@query){
			my $word;
			if ($i =~ /%/){
				$word = "'$i'";
			} else {
				$word = "'%$i%'";
			}
			$sql .= "\t\t\t\tgenkei.name LIKE $word";
			if ($args{method} eq 'AND'){
				$sql .= " AND\n";
			} else {
				$sql .= " OR\n";
			}
		}
		substr($sql,-4,3) = '';
		$sql .= "\t\t\t)\n\t\tORDER BY\n\t\t\tgenkei.num DESC";
		my $t = mysql_exec->select($sql,1);
		$result = $t->hundle->fetchall_arrayref;
		
		if ( ! $args{katuyo} ){         # ���Ѹ�ʤ��ξ��
			foreach my $i (@{$result}){
				pop @{$i};
			}
		} else {                        # ���Ѹ줢��ξ��
			my $result2;
			foreach my $i (@{$result}){
				my $id = pop @{$i};
				push @{$result2}, $i;
				
				my $r = mysql_exec->select("      # ���Ѹ��õ��
					SELECT hyoso.name, katuyo.name, hyoso.num
					FROM hyoso, katuyo
					WHERE
						    hyoso.katuyo_id = katuyo.id
						AND hyoso.genkei_id = $id
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

	} else {                  # ���Ѹ측��
		my $sql;
		$sql = '
			SELECT hyoso.name, hinshi.name, katuyo.name, hyoso.num
			FROM hyoso, genkei, hinshi, katuyo
			WHERE
				    hyoso.genkei_id = genkei.id
				AND genkei.hinshi_id = hinshi.id
				AND hyoso.katuyo_id = katuyo.id AND
		';
		foreach my $i (@query){
			my $word;
			if ($i =~ /%/){
				$word = "'$i'";
			} else {
				$word = "'%$i%'";
			}
			$sql .= "\t\t\t\thyoso.name LIKE $word";
			if ($args{method} eq 'AND'){
				$sql .= " AND\n";
			} else {
				$sql .= " OR\n";
			}
		}
		substr($sql,-4,3) = '';
		$sql .= "ORDER BY hyoso.num DESC";
		$result = mysql_exec->select($sql,1)->hundle->fetchall_arrayref;
	}

	return $result;
}

#-------------------------#
#   CSV�����ꥹ�Ȥν���   #

sub csv_list{
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
		$line .= "$i->[0],,";
	}
	chop $line;
	print LIST "$line\n";
	# 2���ܰʹ�
	my $row = 0;
	while (1){
		my $line = '';
		my $check;
		foreach my $i (@{$list}){
			$line .= "$i->[1][$row][0],$i->[1][$row][1],";
			$check += $i->[1][$row][1];
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

#-----------------------#
#   �и���� �ٿ�ʬ��   #

sub spss_freq{
	my $class = shift;
	my $target = shift;
	
	my $list = &_make_list;

	my $text = '';
	$text .= "data list list(',')\n";
	$text .= "  /��и�(a255) �ʻ�(a10) �и����(f10.0).\n";
	$text .= "BEGIN DATA\n";

	foreach my $i (@{$list}){
		foreach my $h (@{$i->[1]}){
			$text .= "$h->[0],$i->[0],$h->[1]\n";
		}
	}

	$text .= "END DATA.\n";
	$text .= "EXECUTE .\n";
	$text .= "FREQUENCIES\n";
	$text .= "  VARIABLES=�и����\n";
	$text .= "  /NTILES=  4\n";
	$text .= "  /STATISTICS=MEAN MEDIAN MODE SUM\n";
	$text .= "  /ORDER=  ANALYSIS .\n";

	open (LIST,">$target") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$target"
		);
	print LIST $text;
	close (LIST);
	kh_jchar->to_sjis($target);
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
		print "damn!!!!!!!!!!!!\n";
		return;
	}

	my @hinshi = @{$temp};
	# ñ��ꥹ�ȥ��å�
	my @result = ();
	foreach my $i (@hinshi){
		my $sql = '';
		$sql  = "SELECT name, num FROM genkei ";
		$sql .= "WHERE khhinshi_id = $i->[1] ";
		$sql .= "ORDER BY num DESC";
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
	$sql .= "WHERE\n";
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
	return mysql_exec->select($sql,1)->hundle->fetch->[0];
}
sub num_kinds_all{
	return mysql_exec                   # HTML���������ñ���������֤�
		->select("select count(*) from genkei where  khhinshi_id!=99999",1)
			->hundle->fetch->[0];
}
sub num_all{
	return mysql_exec                   # HTML���������ñ������֤�
		->select("select sum(num) from genkei where  khhinshi_id!=99999",1)
			->hundle->fetch->[0];
}

1;
