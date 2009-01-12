package kh_hinshi;
use strict;

sub output{
	
	my $file_cha1 = $::project_obj->file_base.'_chasen1.csv';
	my $file_cha2 = $::project_obj->file_base.'_chasen2.csv';
	my $file_kh1 = $::project_obj->file_base.'_kh1.csv';
	my $file_kh2 = $::project_obj->file_base.'_kh2.csv';

	my $dun_num = mysql_exec->select("select count(*) from dan")
		->hundle->fetch->[0];

	#----------------------#
	#   �ʻ��ٿ�����䥡�   #

	# �ʻ�ꥹ�Ⱥ���
	my @hinshi = @{&list};
	my %l_hinshi;
	my $h = mysql_exec->select("
		SELECT   id, name
		FROM     hinshi
		ORDER BY name
	")->hundle or die;
	while (my $i = $h->fetch){
		$l_hinshi{$i->[1]} = $i->[0];
	}

	# �ʻ�ꥹ�ȤΥ����å�
	my $n = 0;
	foreach my $i (keys %l_hinshi){
		my $chk = 0;
		foreach my $ii (@hinshi){
			if ($i eq $ii){
				$chk = 1;
				last;
			}
		}
		if ( ($chk == 0) && ($i ne '����') ){
			gui_errormsg->open(
				msg  => "error: $i",
				type => 'msg',
				icon => 'info',
			);
			return 0;
		}
	}

	# �ǡ�������
	my $sql = "select\n";
	foreach my $i (@hinshi){
		if ($l_hinshi{$i}){
			$sql .= "\tcount(if(hinshi.id = $l_hinshi{$i},1,NULL)),\n";
		} else {
			$sql .= "\t0,\n";
		}
	}
	chop $sql; chop $sql;
	$sql .= "
		from hyosobun,hyoso,genkei,hinshi,khhinshi
		where
			hyosobun.hyoso_id = hyoso.id
			and hyoso.genkei_id = genkei.id
			and genkei.hinshi_id = hinshi.id
			and genkei.khhinshi_id = khhinshi.id
			and khhinshi.name != 'HTML����'
			and dan_id > 0
		group by h1_id,h2_id,h3_id,h4_id,h5_id,dan_id
		order by hyosobun.id";
	$h = mysql_exec->select($sql)->hundle;

	# �񤭽Ф�
	open (OUT,">$file_cha1") or die;
	my $fstline;                                      # �����
	foreach my $i (@hinshi){
		$fstline .= Jcode->new("$i,")->sjis;
	}
	chop $fstline;
	print OUT "$fstline\n";
	while (my $i = $h->fetch){
		my $line;
		foreach my $ii (@{$i}){
			$line .= "$ii,";
		}
		chop $line;
		print OUT "$line\n";
	}
	close OUT;

	#--------------------------#
	#   �ʻ��̥ꥹ�ȡ���䥡�   #

	# �ǡ�������
	$sql = "
		select dan.id, hyoso.name, hinshi.id
		from hyosobun,hyoso,genkei,hinshi,khhinshi,dan
		where
			hyosobun.hyoso_id = hyoso.id
			and hyoso.genkei_id = genkei.id
			and genkei.hinshi_id = hinshi.id
			and genkei.khhinshi_id = khhinshi.id
			and khhinshi.name != 'HTML����'
			and hyosobun.h1_id = dan.h1_id
			and hyosobun.h2_id = dan.h2_id
			and hyosobun.h3_id = dan.h3_id
			and hyosobun.h4_id = dan.h4_id
			and hyosobun.h5_id = dan.h5_id
			and hyosobun.dan_id = dan.dan_id
		order by hyosobun.id";
	$h = mysql_exec->select($sql)->hundle;
	my $data;
	while (my $i = $h->fetch){
		$data->{$i->[0]}{$i->[2]} .= "$i->[1],"
	}

	# �񤭽Ф�

	open (OUT,">$file_cha2") or die;
	print OUT "$fstline\n";
	for (my $n = 1; $n <= $dun_num; ++$n){
		my $line;
		foreach my $i (@hinshi){
			my $cell = $data->{$n}{$l_hinshi{$i}};
			chop $cell;
			$cell = kh_csv->value_conv($cell);
			$cell = Jcode->new($cell)->sjis;
			$line .= "$cell,";
		}
		chop $line;
		print OUT "$line\n";
	}
	close (OUT);


	#--------------------#
	#   �ʻ��ٿ���KH��   #

	# �ʻ�ꥹ�Ⱥ���
	my %hinshi;
	my $h = mysql_exec->select("
		SELECT   khhinshi_id, name
		FROM     hselection
		WHERE
		             name != 'HTML����'
		         and name != '����'
		ORDER BY khhinshi_id
	")->hundle or die;
	while (my $i = $h->fetch){
		$hinshi{$i->[0]} = $i->[1];
	}

	# SQL����
	my $sql = "select\n";
	foreach my $i (sort {$a <=> $b} keys %hinshi){
		$sql .= "\tcount(if(khhinshi.id = $i,1,NULL)),\n";
	}
	chop $sql; chop $sql;
	$sql .= "
		from hyosobun,hyoso,genkei,hinshi,khhinshi
		where
			hyosobun.hyoso_id = hyoso.id
			and hyoso.genkei_id = genkei.id
			and genkei.hinshi_id = hinshi.id
			and genkei.khhinshi_id = khhinshi.id
			and khhinshi.name != 'HTML����'
			and dan_id > 0
		group by h1_id,h2_id,h3_id,h4_id,h5_id,dan_id
		order by hyosobun.id";
	$h = mysql_exec->select($sql)->hundle;

	# �񤭽Ф�
	open (OUT,">$file_kh1") or die;
	my $fstline;                                      # �����
	foreach my $i (sort {$a <=> $b} keys %hinshi){
		$fstline .= Jcode->new("$hinshi{$i},")->sjis;
	}
	chop $fstline;
	print OUT "$fstline\n";
	while (my $i = $h->fetch){
		my $line;
		foreach my $ii (@{$i}){
			$line .= "$ii,";
		}
		chop $line;
		print OUT "$line\n";
	}
	close OUT;

	#------------------------#
	#   �ʻ��̥ꥹ�ȡ�KH��   #

	# �ǡ�������
	$sql = "
		select dan.id, genkei.name, khhinshi.id
		from hyosobun,hyoso,genkei,hinshi,khhinshi,dan
		where
			hyosobun.hyoso_id = hyoso.id
			and hyoso.genkei_id = genkei.id
			and genkei.hinshi_id = hinshi.id
			and genkei.khhinshi_id = khhinshi.id
			and khhinshi.name != 'HTML����'
			and hyosobun.h1_id = dan.h1_id
			and hyosobun.h2_id = dan.h2_id
			and hyosobun.h3_id = dan.h3_id
			and hyosobun.h4_id = dan.h4_id
			and hyosobun.h5_id = dan.h5_id
			and hyosobun.dan_id = dan.dan_id
		order by hyosobun.id";
	$h = mysql_exec->select($sql)->hundle;
	$data = undef;
	while (my $i = $h->fetch){
		$data->{$i->[0]}{$i->[2]} .= "$i->[1] "
	}

	# �񤭽Ф�

	open (OUT,">$file_kh2") or die;
	print OUT "$fstline\n";
	for (my $n = 1; $n <= $dun_num; ++$n){
		my $line;
		foreach my $i (sort {$a <=> $b} keys %hinshi){
			my $cell = $data->{$n}{$i};
			chop $cell;
			$cell = kh_csv->value_conv($cell);
			$cell = Jcode->new($cell)->sjis;
			$line .= "$cell,";
		}
		chop $line;
		print OUT "$line\n";
	}
	close (OUT);



	gui_errormsg->open(
		msg  => '�ʻ�������Ϥ��ޤ���',
		type => 'msg',
		icon => 'info',
	);
}

# ��䥤��ʻ�ꥹ�Ȥ��֤�
sub list{
	my @list = (
		'̾��-����',
		'̾��-��ͭ̾��-����',
		'̾��-��ͭ̾��-��̾-����',
		'̾��-��ͭ̾��-��̾-��',
		'̾��-��ͭ̾��-��̾-̾',
		'̾��-��ͭ̾��-�ȿ�',
		'̾��-��ͭ̾��-�ϰ�-����',
		'̾��-��ͭ̾��-�ϰ�-��',
		'̾��-��̾��-����',
		'̾��-��̾��-����',
		'̾��-�����ǽ',
		'̾��-������³',
		'̾��-����ư��촴',
		'̾��-��',
		'̾��-��Ω-����',
		'̾��-��Ω-�����ǽ',
		'̾��-��Ω-��ư��촴',
		'̾��-��Ω-����ư��촴',
		'̾��-�ü�-��ư��촴',
		'̾��-����-����',
		'̾��-����-��̾',
		'̾��-����-�ϰ�',
		'̾��-����-������³',
		'̾��-����-��ư��촴',
		'̾��-����-����ư��촴',
		'̾��-����-�����ǽ',
		'̾��-����-������',
		'̾��-����-�ü�',
		'̾��-��³��Ū',
		'̾��-ư����ΩŪ',
		'̾��-����ʸ����',
		'̾��-�ʥ����ƻ�촴',
		'��Ƭ��-̾����³',
		'��Ƭ��-ư����³',
		'��Ƭ��-���ƻ���³',
		'��Ƭ��-����³',
		'ư��-��Ω',
		'ư��-��Ω',
		'ư��-����',
		'���ƻ�-��Ω',
		'���ƻ�-��Ω',
		'���ƻ�-����',
		'����-����',
		'����-��������³',
		'Ϣ�λ�',
		'��³��',
		'����-�ʽ���-����',
		'����-�ʽ���-����',
		'����-�ʽ���-Ϣ��',
		'����-��³����',
		'����-������',
		'����-������',
		'����-�������',
		'����-��Ω����',
		'����-������',
		'����-�����졿��Ω���졿������',
		'����-Ϣ�β�',
		'����-���첽',
		'����-�ü�',
		'��ư��',
		'��ư��',
		'����-����',
		'����-����',
		'����-����',
		'����-����',
		'����-����ե��٥å�',
		'����-��̳�',
		'����-�����',
		'����¾-����',
		'�ե��顼',
		'����첻',
		'������',
		'̤�θ�',
#		'ʣ��̾��',
#		'����'
	);
	return \@list;
}

1;