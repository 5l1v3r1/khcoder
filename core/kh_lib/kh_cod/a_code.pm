package kh_cod::a_code;
use kh_cod::a_code::atom;
use gui_errormsg;
use mysql_exec;
use strict;

sub code{
	my $self           = shift;

	unless ($self->{condition}){
		return 0;
	}
	unless ($self->tables){
		return 0;
	}

	$self->{res_table} = shift;

	mysql_exec->drop_table($self->{res_table});
	mysql_exec->do("
		CREATE TABLE $self->{res_table} (
			id int not null primary key,
			num int
		) type = heap
	",1);

	my $sql = '';
	$sql .= "INSERT INTO $self->{res_table} (id, num)\n";
	$sql .= "SELECT $self->{tani}.id, 1\n";
	$sql .= "FROM $self->{tani}\n";
	foreach my $i (@{$self->tables}){
		$sql .= "\tLEFT JOIN $i ON $self->{tani}.id = $i.id\n";
	}
	$sql .= "WHERE\n";
	foreach my $i (@{$self->{condition}}){
		$sql .= "\t".$i->expr."\n";
	}
	
	my $check = mysql_exec->do($sql);             # ��ʸ���顼�����ä����
	if ($check->err){
		$self->{res_table} = '';
		gui_errormsg->open(
			type => 'msg',
			msg  =>
				"�����ǥ��󥰡��롼��ν񼰤˸�꤬����ޤ�����\n".
				"����ޤॳ���ɡ� ".$self->name
		);
		return 0;
	}
	
	if ($self->tables){                           # ����ơ��֥�κ��
		foreach my $i (@{$self->tables}){
			mysql_exec->drop_table($i);
		}
	}
	return $self;
}

sub tables{
	my $self = shift;
	return $self->{tables};
}

sub ready{
	my $self = shift;
	my $tani = shift;
	$self->{tani} = $tani;
	unless ($self->{condition}){
		return 0;
	}
	
	# ATOM���ȤΥơ��֥�����
	my ($n0, $n1,@t,$unique_check) = (0,0); 
	foreach my $i (@{$self->{condition}}){
		$i->ready($tani);
		if ($i->tables){
			$n0 += @{$i->tables};
			if ($n0 > 25){
				++$n1; $n0 = 0;
			}
			$i->parent_table("ct_$tani"."_$n1");
			foreach my $h (@{$i->tables}){
				if ($unique_check->{$n1}{$h}){
					next;
				} else {
					push @{$t[$n1]}, $h;
					$unique_check->{$n1}{$h} = 1;
				}
			}
		}
	}
	unless ($unique_check){return 0;}
	
	# ATOM�ơ��֥��ޤȤ��
	my $n = 0;
	foreach my $i (@t){
		# �ơ��֥����
		mysql_exec->drop_table("ct_$tani"."_$n");
		my $sql =
			"CREATE TABLE ct_$tani"."_$n ( id int primary key not null,\n";
		foreach my $h (@{$i}){
			my $col = (split /\_/, $h)[2].(split /\_/, $h)[3];
			$sql .= "$col INT,"
		}
		chop $sql;
		$sql .= ') TYPE = HEAP ';
		mysql_exec->do($sql,1);
		push @{$self->{tables}}, "ct_$tani"."_$n";
		
		# INSERT
		$sql = '';
		$sql .= "INSERT INTO ct_$tani"."_$n\n(id,";
		foreach my $h (@{$i}){
			my $col = (split /\_/, $h)[2].(split /\_/, $h)[3];
			$sql .= "$col,";
		}
		chop $sql;
		$sql .= ")\n";
		$sql .= "SELECT $tani.id,";
		foreach my $h (@{$i}){
			$sql .= "$h.num,";
		}
		chop $sql;
		$sql .= "\n";
		$sql .= "FROM $tani \n";
		foreach my $h (@{$i}){
			$sql .= "\tLEFT JOIN $h ON $tani.id = $h.id\n"
		}
		$sql .= "WHERE ";
		my $nn = 0;
		foreach my $h (@{$i}){
			if ($nn){ $sql .= ' OR '; }
			$sql .= " $h.num ";
			++$nn;
		}
		mysql_exec->do($sql,1);
		
		++$n;
	}
	return $self;
}

sub new{
	my $self;
	my $class = shift;
	$self->{name} = shift;
	$self->{row_condition} = shift;
	
	my $condition = Jcode->new($self->{row_condition},'euc')->tr('��',' ');
	$condition =~ tr/\t\n/  /;
	my @temp = split / /, $condition;
	
	foreach my $i (@temp){
		unless ( length($i) ){next;}
		push @{$self->{condition}}, kh_cod::a_code::atom->new($i);
	}
	
	bless $self, $class;
	return $self;
}

sub name{
	my $self = shift;
	return $self->{name};
}




1;