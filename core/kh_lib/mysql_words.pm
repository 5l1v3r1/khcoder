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



#----------------------#
#   �Ƽ���и�ꥹ��   #

sub word_list_custom{
	use kh_csv;
	my $class = shift;
	my $self = { @_ };
	bless $self, $class;

	my $method = "_make_wl_".$self->{type};
	my $table_data = $self->$method;

	my $method_out = "_out_file_".$self->{ftype}."_".$self->{type};
	my $target = $self->$method_out($table_data);
	
	return $target;
}

sub _out_file_xls{
	my $self = shift;
	my $table_data = shift;

	#----------------#
	#   ���Ϥν���   #

	use Spreadsheet::WriteExcel;
	use Unicode::String qw(utf8 utf16);

	my $f    = $::project_obj->file_TempExcel;
	my $workbook  = Spreadsheet::WriteExcel->new($f);
	my $worksheet = $workbook->add_worksheet(
		utf8( Jcode->new('������1')->utf8 )->utf16,
		1
	);
	$worksheet->hide_gridlines(1);

	my $font = '';
	if ($] > 5.008){
		$font = gui_window->gui_jchar('�ͣ� �Х����å�', 'euc');
	} else {
		$font = 'MS PGothic';
	}
	$workbook->{_formats}->[15]->set_properties(
		font       => $font,
		size       => 11,
		valign     => 'vcenter',
		align      => 'center',
	);
	my $format_n = $workbook->add_format(         # ����
		num_format => '0',
		size       => 11,
		font       => $font,
		align      => 'right',
	);
	my $format_c = $workbook->add_format(         # ʸ����
		font       => $font,
		size       => 11,
		align      => 'left',
		num_format => '@'
	);

	#----------#
	#   ����   #

	my $row = 0;
	foreach my $i (@{$table_data}){
		if ($row >= 65536 ){
			gui_errormsg->open(
				msg  => "Excel�����ե���������¤Τ��ᡢ65,536�Ԥ�ۤ�����ʬ�Υǡ����Ͻ��Ϥ��ޤ���Ǥ�����\n������ʬ�Υǡ�������Ϥ���ˤϡ�CSV���������򤷤Ƥ���������",
				type => 'msg',
			);
			last;
		}
		
		my $col = 0;
		foreach my $h (@{$i}){
			unless ( defined($h) ){
				++$col;
				next;
			}
			unless ( length($h) ){
				++$col;
				next;
			}
		
			if ($h =~ /^[0-9]+$/o ){
				$worksheet->write_number(
					$row,
					$col,
					$h,
					$format_n
				);
			} else {
				$worksheet->write_string(
					$row,
					$col,
					gui_window->gui_jchar($h, 'euc'), # Perl 5.8�ʹߤ�ɬ��
					# Perl 5.6�ξ�硧
					# utf8( Jcode->new($h,'euc')->utf8 )->utf16,
					$format_c
				);
			}
			++$col;
		}
		++$row;
	}

	#------------#
	#   ������   #
	$worksheet->freeze_panes(1, 0);     # ��Window�Ȥθ����

	if ( $self->{type} eq '1c' ){       # ��1��פΥꥹ�Ȥˤϥ����ȥե��륿��
		$worksheet->autofilter(0, 1, $row - 1, 1);
	}

	$workbook->close;
	return $f;
}

*_out_file_xls_def = *_out_file_xls_1c = \&_out_file_xls;

sub _out_file_xls_150{
	my $self = shift;
	my $table_data = shift;

	#----------------#
	#   ���Ϥν���   #

	use Spreadsheet::WriteExcel;
	use Unicode::String qw(utf8 utf16);

	my $f    = $::project_obj->file_TempExcel;
	my $workbook  = Spreadsheet::WriteExcel->new($f);
	my $worksheet = $workbook->add_worksheet(
		utf8( Jcode->new('������1')->utf8 )->utf16,
		1
	);
	$worksheet->hide_gridlines(1);

	my $font = '';
	if ($] > 5.008){
		$font = gui_window->gui_jchar('�ͣ� �Х����å�', 'euc');
	} else {
		$font = 'MS PGothic';
	}
	$workbook->{_formats}->[15]->set_properties(
		font       => $font,
		size       => 11,
		valign     => 'vcenter',
		align      => 'center',
	);

	my $format_n = $workbook->add_format(
		font       => $font,
		size       => 11,
	);
	my $format_t = $workbook->add_format(
		font       => $font,
		size       => 11,
		top        => 1,
	);
	my $format_tb = $workbook->add_format(
		font       => $font,
		size       => 11,
		top        => 1,
		bottom     => 1,
	);
	my $format_b = $workbook->add_format(
		font       => $font,
		size       => 11,
		bottom     => 1,
	);


	#----------#
	#   ����   #

	my $row = 0;
	foreach my $i (@{$table_data}){
		my $col = 0;
		foreach my $h (@{$i}){
			$h = gui_window->gui_jchar($h, 'euc') unless $h =~ /^[0-9]+$/o;

			my $f;
			if ($row == 0){
				if ($col == 2 || $col == 5){
					$f = $format_t;
				} else {
					$f = $format_tb;
				}
			}
			elsif ($row == 50){
				$f = $format_b;
			} else {
				$f = $format_n;
			}

			$worksheet->write(
				$row,
				$col,
				$h,
				$f
			);

			++$col;
		}
		++$row;
	}

	#------------#
	#   ������   #
	#$worksheet->freeze_panes(1, 0);
	$worksheet->set_column(2, 2, 2);
	$worksheet->set_column(5, 5, 2);

	$workbook->close;
	return $f;
}

sub _out_file_csv{
	my $self       = shift;
	my $table_data = shift;

	# �ꥹ�ȹ�¤��ƥ����Ȥ˽���
	my $target = $::project_obj->file_TempCSV;

	open (LIST,">$target") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$target"
		);

	foreach my $i (@{$table_data}){
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
	
	return $target;
}

*_out_file_csv_def = *_out_file_csv_1c = *_out_file_csv_150 = \&_out_file_csv;

sub _make_wl_1c{
	my $self = shift;

	my $list;
	if ($self->{num} eq 'tf'){
		$list = &_make_list;
	} else {
		$list = &_make_list_df($self->{tani});
	}

	my @data;
	foreach my $i (@{$list}){
		foreach my $h (@{$i->[1]}){
			push @data, [ $h->[0], $i->[0] ,$h->[1]  ];
		}
	}

	@data = sort { 
		   $b->[2] <=> $a->[2]
		or $a->[0] cmp $b->[0]
		or $a->[1] cmp $b->[1]
	} @data;

	my $num_lab = '';
	if ($self->{num} eq 'tf'){
		$num_lab = '�и����';
	} else {
		my $tani = $self->{tani};
		$tani = 'ʸ'   if $self->{tani} eq 'bun';
		$tani = '����' if $self->{tani} eq 'dan';
		$num_lab = 'ʸ�����'.$tani.'��';
	}

	my @data = (['��и�', '�ʻ�', $num_lab], @data);

	return \@data;
}

sub _make_wl_def{
	my $self = shift;
	
	my $list;
	if ($self->{num} eq 'tf'){
		$list = &_make_list;
	} else {
		$list = &_make_list_df($self->{tani});
	}

	my $num_lab = '';
	if ($self->{num} eq 'tf'){
		$num_lab = '';
	} else {
		my $tani = $self->{tani};
		$tani = 'ʸ'   if $self->{tani} eq 'bun';
		$tani = '����' if $self->{tani} eq 'dan';
		$num_lab = 'ʸ�����'.$tani.'��';
	}

	my @data;

	# 1����
	my @line = ();
	foreach my $i (@{$list}){
		push @line, $i->[0];
		push @line, $num_lab;
	}
	push @data, \@line;

	# 2���ܰʹ�
	my $row = 0;
	while (1){
		my @line = ();
		my $check;
		foreach my $i (@{$list}){
			$i->[1][$row][1] = '' unless defined($i->[1][$row][1]);
			$i->[1][$row][0] = '' unless defined($i->[1][$row][0]);
			push @line, $i->[1][$row][0];
			push @line, $i->[1][$row][1];
			$check += $i->[1][$row][1] if $i->[1][$row][1];
		}
		unless ($check){
			last;
		}
		push @data, \@line;
		++$row;
	}
	
	return \@data;
}

sub _make_wl_150{
	my $self = shift;
	
	my $t;
	my @data = ();
	if ($self->{num} eq 'tf'){
		$t = mysql_exec->select('
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
			  and hselection.name != "���ƻ����Ω��"
			  and hselection.ifuse = 1
			  and genkei.nouse = 0
			ORDER BY TF DESC, W
			LIMIT 150
		',1)->hundle;
		$data[0] = ['��и�','�и���','','��и�','�и���','','��и�','�и���'];
	} else {
		$t = mysql_exec->select('
			SELECT
			  genkei.name   as W,
			  f             as DF
			FROM hselection, genkei
			  LEFT JOIN df_'.$self->{tani}.' ON genkei_id = genkei.id
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
			  and genkei.nouse = 0
			ORDER BY DF DESC, W
			LIMIT 150
		',1)->hundle;
		
		my $tani = $self->{tani};
		$tani = 'ʸ'   if $self->{tani} eq 'bun';
		$tani = '����' if $self->{tani} eq 'dan';
		
		$data[0] = [
			   '��и�','ʸ�����'.$tani.'��',
			'','��и�','ʸ�����'.$tani.'��',
			'','��и�','ʸ�����'.$tani.'��',
		];
	}

	# �ꥹ�ȹ�¤����
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

	return \@data;
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
		print "oh, well, I don't know what to do...\n";
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

sub _make_list_df{
	my $tani = shift;

	my $temp = &_make_hinshi_list;
	unless (eval (@{$temp})){
		print "oh, well, I don't know what to do...\n";
		return;
	}

	my @hinshi = @{$temp};
	# ñ��ꥹ�ȥ��å�
	my @result = ();
	foreach my $i (@hinshi){
		my $sql;
		if ($i->[0] eq '����¾'){
			$sql  = "
				SELECT concat(genkei.name,'(',hinshi.name,')'), f
				FROM hinshi, genkei
					LEFT JOIN df_$tani ON genkei_id = genkei.id
				WHERE
					genkei.hinshi_id = hinshi.id
					and khhinshi_id = $i->[1]
					and genkei.nouse = 0
				ORDER BY f DESC, genkei.name
			";
		} else {
			$sql  = "
				SELECT name, f FROM genkei
					LEFT JOIN df_$tani ON genkei_id = genkei.id
				WHERE
					khhinshi_id = $i->[1]
					and genkei.nouse = 0
				ORDER BY f DESC, name
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
	$sql .= " 1 " unless $n;
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
