package kh_cod::a_code::atom;
use strict;

use kh_cod::a_code::atom::delimit;
use kh_cod::a_code::atom::word;
use kh_cod::a_code::atom::code;
use kh_cod::a_code::atom::hinshi;
use kh_cod::a_code::atom::string;
use kh_cod::a_code::atom::number;
use kh_cod::a_code::atom::length;
use kh_cod::a_code::atom::outvar_o;
use kh_cod::a_code::atom::heading;
use kh_cod::a_code::atom::phrase;
use kh_cod::a_code::atom::near;
use kh_cod::a_code::atom::sequence;

use mysql_exec;
use POSIX qw(log10);

BEGIN {
	use vars qw(@pattern);
	push @pattern, [
		kh_cod::a_code::atom::heading->pattern,
		kh_cod::a_code::atom::heading->name
	];
	push @pattern, [
		kh_cod::a_code::atom::outvar_o->pattern,
		kh_cod::a_code::atom::outvar_o->name
	];
	push @pattern, [
		kh_cod::a_code::atom::length->pattern,
		kh_cod::a_code::atom::length->name
	];
	push @pattern, [
		kh_cod::a_code::atom::number->pattern,
		kh_cod::a_code::atom::number->name
	];
	push @pattern, [
		kh_cod::a_code::atom::string->pattern,
		kh_cod::a_code::atom::string->name
	];
	push @pattern, [
		kh_cod::a_code::atom::hinshi->pattern,
		kh_cod::a_code::atom::hinshi->name
	];
	push @pattern, [
		kh_cod::a_code::atom::code->pattern,
		kh_cod::a_code::atom::code->name
	];
	push @pattern, [
		kh_cod::a_code::atom::near->pattern,
		kh_cod::a_code::atom::near->name
	];
	push @pattern, [
		kh_cod::a_code::atom::sequence->pattern,
		kh_cod::a_code::atom::sequence->name
	];
	push @pattern, [
		kh_cod::a_code::atom::phrase->pattern,
		kh_cod::a_code::atom::phrase->name
	];
	push @pattern, [
		kh_cod::a_code::atom::delimit->pattern,
		kh_cod::a_code::atom::delimit->name
	];
	push @pattern, [
		kh_cod::a_code::atom::word->pattern,
		kh_cod::a_code::atom::word->name
	];
}

sub new{
	my $self;
	my $class = shift;
	$self->{raw} = shift;
	
	foreach my $i (@pattern){
		if ($self->{raw} =~ /$i->[0]/){
			# print Jcode->new("$self->{raw}, $i->[1]\n")->sjis;
			$class .= '::'."$i->[1]";
			last;
		}
	}
	
	bless $self, $class;
	$self->when_read;
	return $self;
}

sub num_expr{
	my $self = shift;
	my $sort = shift;
	
	my $t = $self->expr;
	
	if ($sort eq 'tf*idf'){
		$t .= " * ".$self->idf;
	}
	elsif ($sort eq 'tf/idf'){
		$t .= " / ".$self->idf;
	}
	#print Jcode->new("$sort : ".$self->raw." : $t \n")->sjis;
	
	return $t;
}

sub idf{
	# �f�t�H���g��IDF�l
		# �O���ϐ��Ȃǂ̎w��ł́A�u�e�������Ɋ܂܂��m����50%�̌�i���Ȃ킿
		# �S�����̂��������̕����Ɋ܂܂���j���A���Y��������1��o�����Ă����v
		# �̂Ɠ����X�R�A��^����B
		# �u�S�����̂��������i50%�j�v�Ƃ��������������Őݒ�B
	my $self = shift;
	die("No tani definition!\n") unless $self->{tani};
	return log10( 2 / 1 );
}

sub clear{
	return 1;
}

sub raw{
	my $self = shift;
	return $self->{raw};
}

sub when_read{
	return 1;
}
sub hyosos{
	return undef;
}
sub strings{
	return undef;
}

sub cache_check{
	my $self = shift;
	my %args = @_;

	# �L���b�V�����X�g�����݂���ꍇ
	if ( mysql_exec->table_exists('ct_cache_tables') ){
		# ���ɃL���b�V�������邩�ǂ���������
		my $h = mysql_exec->select("
			SELECT id
			FROM ct_cache_tables
			WHERE 
				    tani = \"$args{tani}\"
				AND kind = \"$args{kind}\"
				AND name = '$args{name}'
		",1)->hundle;
		my $n = $h->fetch;
		# �L���b�V�������݂����ꍇ
		if ($n){
			return (1,$n->[0]);
		} 
		# �L���b�V�������݂��Ȃ������ꍇ
		else {
			# �V�K�L���b�V���Ƃ��ēo�^
			mysql_exec->do("
				INSERT INTO ct_cache_tables (tani,kind,name)
				VALUES (\"$args{tani}\", \"$args{kind}\",\"$args{name}\")
			",1);
			# �ԍ���Ԃ�
			$n = mysql_exec->select("
				SELECT MAX(id)
				FROM   ct_cache_tables
			",1)->hundle->fetch->[0];
			return (0, $n);
		}
	}
	# �L���b�V�����X�g�����݂��Ȃ������ꍇ
	else {
		mysql_exec->do("
			CREATE TABLE ct_cache_tables (
				id   int auto_increment primary key not null,
				tani varchar(5),
				kind varchar(20),
				name text
			)
		",1);
		mysql_exec->do("
			INSERT INTO ct_cache_tables (tani,kind,name)
			VALUES (\"$args{tani}\", \"$args{kind}\",\"$args{name}\")
		",1);
		return (0,1);
	}
}




1;