package mysql_ready;
use strict;
use DBI;
use Jcode;
use Benchmark;

use kh_project;
use kh_jchar;
use mysql_exec;
#use mysql_ready::readin;

#--------------------------#
#   �����ǲ���ľ��ν���   #
#--------------------------#

sub first{
	
	my $class = shift;
	my $self;
	$self->{dbh} = $::project_obj->dbh;
#	$class .= '::readin';
	bless $self, $class;
#	$self->readin

	# ��䥤ν��Ϥ�EUC���Ѵ�
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_euc($::project_obj->file_MorphoOut);
	}

	# ���ǡ������ɤ߹���
	mysql_exec->do("drop table rowdata");
	mysql_exec->do("create table rowdata
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
	mysql_exec->do("LOAD DATA LOCAL INFILE $thefile INTO TABLE rowdata",1);

	# �פ�ʤ��ե�����ɤ�ΤƤ�
	my $t0 = new Benchmark;
#	mysql_exec->do("ALTER TABLE rowdata DROP yomi",1);
#	mysql_exec->do("ALTER TABLE rowdata DROP katuyo",1);

	# Ĺ������ե�����ɤ�û��
	my $t = mysql_exec->select("
		SELECT
			MAX( LENGTH(hyoso) ) AS hyoso,
			MAX( LENGTH(genkei) ) AS genkei,
			MAX( LENGTH(hinshi) ) AS hinshi,
			MAX( LENGTH(katuyo) ) AS katuyo
		FROM rowdata
	",1)->hundle;
	my $r = $t->fetchrow_hashref;
	foreach my $key (keys %{$r}){
		my $len = $r->{$key} + 4;
#		my $len = 255;
		$self->length($key,$len);
		if ($len < 200){
			mysql_exec->do("ALTER TABLE rowdata MODIFY $key varchar($len)",1);
		}
		if ($len > 255){
			$self->length($key,255);
		}
	}
	my $t1 = new Benchmark;
	print timestr(timediff($t1,$t0)),"\n";

	my $t2 = new Benchmark;
	
	# ����å��塦�ơ��֥����
	mysql_exec->do("drop table hgh");
	my @len = (
		$self->length('hyoso'),
		$self->length('genkei'),
		$self->length('hinshi'),
		$self->length('katuyo')
	);
	mysql_exec->do("
		create table hgh (
			id int auto_increment primary key not null,
			num int not null,
			hyoso varchar($len[0]) not null,
			genkei varchar($len[1]) not null,
			hinshi varchar($len[2]) not null,
			katuyo varchar($len[3]) not null
		)
	" or 1);
	mysql_exec->do("
		INSERT
		INTO hgh ( num, hyoso, genkei, hinshi, katuyo)
		SELECT COUNT(*), hyoso, genkei, hinshi, katuyo
			FROM rowdata
#			WHERE LENGTH(rowdata.genkei) > 1
			GROUP BY rowdata.hyoso, rowdata.genkei, rowdata.hinshi
	", 1);

	# �ʻ�ơ��֥����
	my $len = $self->length('hinshi');
	mysql_exec->do("drop table hinshi");
	mysql_exec->do("
		create table hinshi (
			id int auto_increment primary key not null,
			name varchar($len) not null
		)
	",1);
		
	mysql_exec->do('
		INSERT
		INTO hinshi (name)
		SELECT (hinshi)
			FROM hgh
			WHERE length(genkei) > 1
			GROUP BY hinshi
	',1);
	mysql_exec->do("alter table hinshi add index index1 (name)",1);
	
	# �����ơ��֥����

	$len = $self->length('genkei');                         # �ơ��֥����
	mysql_exec->do("drop table genkei");
	mysql_exec->do("
		create table genkei (
			id int auto_increment primary key not null,
			name varchar($len) not null,
			num int not null,
			hinshi_id int not null,
			khhinshi_id int not null
		)
	",1);

	my $dbhh = DBI->connect("DBI:CSV:f_dir=./config");      # ʬ�൬§����
	my $th = $dbhh->prepare("
		SELECT kh_hinshi,condition1,condition2,hinshi_id
		FROM hinshi_chasen
	") or die;
	$th->execute or die;
	my $rule = $th->fetchall_arrayref;

                                                            # �ǡ�������
	my $td = mysql_exec->select('
		SELECT hgh.genkei, SUM(num), hinshi.id, hinshi.name
			FROM hgh, hinshi
			WHERE hgh.hinshi=hinshi.name
			GROUP BY hgh.genkei, hgh.hinshi
	',1)->hundle;

	my ($num, $con) = (0,'');
	while (my $d = $td->fetch){                             # ����ʬ��
		my $kh_hinshi = '9999';
		foreach my $i (@{$rule}){
			if ( index("$d->[3]","$i->[1]") == 0 ){        # ���1
				if ($i->[2] eq '�Ҥ餬��'){            # ���2:�Ҥ餬��
					if ($d->[0] =~ /^(\xA4[\xA1-\xF3])+$/o){
						$kh_hinshi = $i->[3];
						last;
					}
				}
				elsif ($i->[2] eq '��ʸ��'){         # ���2:�Ҥ餬��
					if (length($d->[0]) == 2){
						$kh_hinshi = $i->[3];
						last;
					}
				}
				elsif ($i->[2] eq 'HTML'){         # ���3:HTML
					if ( 
						   ($d->[0] =~ /<h[1-5]>/io)
						|| ($d->[0] =~ /<\/h[1-5]>/io) 
					){
						$kh_hinshi = $i->[3];
						last;
					}
				}
				else {                                 # ���2̵���ξ��
					$kh_hinshi = $i->[3];
					last;
				}
			}
		}
		$con .= "('$d->[0]',$d->[1],$d->[2],$kh_hinshi),";
		++$num;
		if ($num == 200){                              # DB������
			chop $con;
			mysql_exec->do("
				INSERT
				INTO genkei (name, num, hinshi_id, khhinshi_id)
				VALUES $con
			",1);
			$con = '';
			$num = 0;
		}
	}
	if ($con){                                         # �Ĥ��DB������
		chop $con;
		mysql_exec->do("
			INSERT
			INTO genkei (name, num, hinshi_id, khhinshi_id)
			VALUES $con
		",1);
	}
	mysql_exec->do('alter table genkei add index index1(name,hinshi_id,khhinshi_id)',1);

	# KH_�ʻ�ơ��֥�κ���
	mysql_exec->do("drop table khhinshi");
	mysql_exec->do("
		create table khhinshi (
			id int primary key not null,
			name varchar(20) not null
		)
	",1);

	$con = ''; my %temp;
	foreach my $i (@{$rule}){
		unless ($temp{$i->[0]}){
			$con .= "($i->[3],'$i->[0]'),";
			$temp{$i->[0]} = 1;
		}
	}
	$con .= "(9999,'����¾')";

	mysql_exec->do("
		INSERT
		INTO khhinshi (id,name)
		VALUES $con
	",1);
	mysql_exec->do('alter table khhinshi add index index1(name,id)',1);

	# ����å���ơ��֥�(2)����
	mysql_exec->do("drop table hghi");
	mysql_exec->do("
		create table hghi (
			hyoso varchar($len[0]) not null,
			genkei varchar($len[1]) not null,
			hinshi varchar($len[2]) not null,
			katuyo varchar($len[3]) not null,
			hyoso_id int not null primary key,
			genkei_id int not null,
			hinshi_id int not null,
			num       int not null
		)
	",1);
	mysql_exec->do('
		INSERT
		INTO hghi (hyoso, genkei, hinshi, katuyo, hyoso_id, genkei_id, hinshi_id, num)
		SELECT hgh.hyoso, hgh.genkei, hgh.hinshi, hgh.katuyo, hgh.id, genkei.id, hinshi.id, hgh.num
			FROM hgh, genkei, hinshi
			WHERE
				    hgh.genkei = genkei.name
				AND hgh.hinshi = hinshi.name
				AND genkei.hinshi_id = hinshi.id
	',1); 
	mysql_exec->do("drop table hgh");
	if ($len[0] + $len[1] + $len[2] <= 500){
		mysql_exec->do(
			"alter table hghi add index index1 (hyoso, genkei, hinshi)",
			1
		);
	} else {
		mysql_exec->do("alter table hghi add index index1 (hyoso)",1);
		mysql_exec->do("alter table hghi add index index2 (genkei)",1);
		mysql_exec->do("alter table hghi add index index3 (hinshi)",1);
		mysql_exec->do("alter table hghi add index index4 (katuyo)",1);
	}

	# ���ѥơ��֥����
	mysql_exec->do("drop table katuyo");
	mysql_exec->do ("
		create table katuyo (
			id int auto_increment primary key not null,
			name varchar($len[3])
		)
	",1);
	mysql_exec->do("
		INSERT INTO katuyo ( name )
		SELECT katuyo FROM hghi
		GROUP BY katuyo
	",1);
	mysql_exec->do("alter table katuyo add index index1 (id, name)",1);


	# ɽ�إơ��֥����
	mysql_exec->do("drop table hyoso");
	mysql_exec->do("
		create table hyoso (
			id int not null primary key,
			name varchar($len[0]) not null,
			len int not null,
			katuyo_id int not null,
			genkei_id int not null,
			num int not null
		)
	",1);
	mysql_exec->do("
		INSERT
		INTO hyoso (id, name, len, genkei_id, num, katuyo_id)
		SELECT hyoso_id, hyoso, LENGTH(hyoso), genkei_id, num, katuyo.id
			FROM hghi, katuyo
			WHERE hghi.katuyo = katuyo.name
	",1);
	mysql_exec->do("alter table hyoso add index index1 (name, genkei_id)",1);

	# ɽ��-ʸ�ơ��֥����

	$t = mysql_exec->select("        # HTML�����ȶ�������hyoso.id�����
		SELECT hyoso.name, hyoso.id
		FROM hyoso
		WHERE
			   (( name RLIKE '<[Hh][1-5]\>' ) AND ( len = 4 ))
			OR (( name RLIKE '</[Hh][1-5]>' ) AND ( len = 5 ))
			OR ( name = '��' )
	",1)->hundle;
	my $IDs;
	while (my $d = $t->fetch){
		$IDs->{$d->[1]} = $d->[0];
	}

	mysql_exec->do("drop table hyosobun");   # �ơ��֥����
	mysql_exec->do("
		create table hyosobun (
			id int auto_increment primary key not null,
			hyoso_id INT not null,
			h1_id INT not null,
			h2_id INT not null,
			h3_id INT not null,
			h4_id INT not null,
			h5_id INT not null,
			dan_id INT not null,
			bun_id INT not null,
			bun_idt INT not null
		)
	",1);

	$t = mysql_exec->select("
		SELECT rowdata.id, hghi.hyoso_id
			FROM rowdata, hghi
			WHERE
					    rowdata.hyoso  = hghi.hyoso
					AND rowdata.genkei = hghi.genkei
					AND rowdata.hinshi = hghi.hinshi
#			ORDER BY rowdata.id
	",1)->hundle;

	my ($bun, $dan, $h5, $h4, $h3, $h2, $h1, $lastrow, $midashi, $bun2) = 
		(1,1,0,0,0,0,0,0,0,0);
	my ($temp, $c, $maru);
	while (my $d = $t->fetch){
		if ($d->[0] - $lastrow > 1){              # ���ԤΥ����å�
			++$dan;
			$bun = 1;
			unless ($maru){
				++$bun2;
			}
		}
		$lastrow = $d->[0];
		if ( $IDs->{$d->[1]} eq '<h1>'){          # HTML���ϥ����Υ�?��å?
			++$h1;
			($h2,$h3,$h4,$h5,$dan,$bun,$midashi)
				= (0,0,0,0,0,0,1);
		}
		elsif ( $IDs->{$d->[1]} eq '<h2>'){
			++$h2;
			($h3,$h4,$h5,$dan,$bun,$midashi)
				= (0,0,0,0,0,1)
		}
		elsif ( $IDs->{$d->[1]} eq '<h3>'){
			++$h3;
			($h4,$h5,$dan,$bun,$midashi)
				= (0,0,0,0,1)
		}
		elsif ( $IDs->{$d->[1]} eq '<h4>'){
			++$h4;
			($h5,$dan,$bun,$midashi)=(0,0,0,1)
		}
		elsif ( $IDs->{$d->[1]} eq '<h5>'){
			++$h5;
			($dan,$bun,$midashi)=(0,0,1)
		}

		                                          # DB�˽񤭹���
		$temp .= "($bun2,$bun,$dan,$h5,$h4,$h3,$h2,$h1,$d->[1]),";
		++$c;
		if ($c == 200){
			chop $temp;
			mysql_exec->do("
				INSERT INTO hyosobun
				(bun_idt, bun_id, dan_id, h5_id, h4_id, h3_id, h2_id, h1_id,hyoso_id)
				VALUES
					$temp
			",1);
			$temp = '';
			$c    = 0;
		}
		if ($IDs->{$d->[1]} eq '��'){             # �������Υ����å�
			unless ($midashi){
				++$bun; ++$bun2; $maru = 1;
			}
		} else {
			$maru = 0;
		}
		if ($IDs->{$d->[1]} =~ /<\/[Hh][1-5]>/){  # HTML��λ�����Υ����å�
				$midashi = 0;
		}
	}
	if ($temp){
		chop $temp;
		mysql_exec->do("
			INSERT INTO hyosobun
			   (bun_idt, bun_id, dan_id, h5_id, h4_id, h3_id, h2_id, h1_id,hyoso_id)
				VALUES
					$temp
		",1);
	}

	my $t3 = new Benchmark;
	print timestr(timediff($t3,$t1)),"\n";

	# ����ǥå�����Ž��
	mysql_exec->do("
		alter table hyosobun add index index1
			(h1_id, h2_id, h3_id, h4_id, h5_id)
	",1);
	mysql_exec->do("
		alter table hyosobun add index index2
			(bun_id, dan_id, bun_idt, hyoso_id)
	",1);
#	mysql_exec->do("
#		alter table hyosobun add index index3
#			(hyoso_id)
#	",1);
#	mysql_exec->do("
#		alter table hyosobun add index index4
#			(bun_idt)
#	",1);

}

#--------------#
#   ��������   #
#--------------#

sub dbh{
	my $self=shift;
	return $self->{dbh};
}
sub length{
	my $self   = shift;
	my $name   = shift;
	my $length = shift;
	
	if ($length){
		$self->{length}{$name} = $length;
	} else {
		if ($self->{length}{$name}){
			return $self->{length}{$name};
		} else {
			return 255;
		}
	}
}

1;
