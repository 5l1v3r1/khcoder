# ����������Ƥ��륳���ɤ����� --- <��������̾>

package kh_cod::a_code::atom::code;
use base qw(kh_cod::a_code::atom);
use strict;

my $num = 0;

sub reset{
	$num = 0;
}

#--------------------#
#   WHERE����SQLʸ   #
#--------------------#

sub expr{
	my $self = shift;
	
	if ($self->{tables}){
		my $col = (split /\_/, $self->{tables}[0])[2].(split /\_/, $self->{tables}[0])[3];
		return "IFNULL(".$self->parent_table.".$col,0)";
	} else {
		return ' 0 ';
	}
}


#---------------------------------------#
#   �����ǥ��󥰽�����tmp table������   #
#---------------------------------------#

sub ready{
	my $self = shift;
	my $tani = shift;
	
	# �����ǥ��󥰤��¹Ԥ���Ƥ��ʤ��ä����ϡ������Ǽ¹�
	unless (
		   $self->{the_code}->if_done == 1 
		&& $self->{the_code}->tani    eq $tani
	){
		$self->{the_code}->ready($tani);
		$self->{the_code}->code("ct_$tani"."_atomcode2_$num");
	}
	
	$self->{hyosos} = $self->{the_code}->hyosos;
	
	if ($self->{the_code}->res_table){
		# �������ơ��֥�̾�κ��������å�
		my $table  = "ct_$tani"."_atomcode_$num";
		push @{$self->{tables}}, $table;
		++$num;
		# �ơ��֥�򥳥ԡ�
		my $oldtab = $self->{the_code}->res_table;
		mysql_exec->drop_table($table);
		mysql_exec->do("
			CREATE TABLE $table (
				id INT primary key not null,
				num INT
			) TYPE = HEAP
		",1);
		mysql_exec->do("
			INSERT INTO $table (id, num)
			SELECT id, num FROM $oldtab
		",1);
	} else {
		$self->{tables} = 0;
	}
	return $self;
}
sub clear{
	my $self = shift;
	$self->{the_code}->clear;
}


#----------------------------#
#   �������ɤ߹��߻��ν���   #

sub when_read{
	my $self = shift;
	
	my $cod_name = $self->raw;
	chop $cod_name;
	substr($cod_name,0,1) = '';
	
	$self->{the_code} = $kh_cod::reading{$cod_name};
	return $self;
}

#-------------------------------#
#   ���Ѥ���tmp table�Υꥹ��   #

sub tables{
	my $self = shift;
	return $self->{tables};
}

#----------------#
#   �ƥơ��֥�   #
sub parent_table{
	my $self = shift;
	my $new  = shift;
	
	if (length($new)){
		$self->{parent_table} = $new;
	}
	return $self->{parent_table};
}

sub hyosos{
	my $self = shift;
	return $self->{hyosos};
}
sub pattern{
	return '^<.+>$';
}
sub name{
	return 'code';
}

1;