package kh_cod::search;
use base qw(kh_cod);
use strict;

# ���ړ��̓R�[�h�̓ǂݍ���
sub add_direct{
	my $self   = shift;
	my $direct = shift;
	
	# ���ɒǉ�����Ă����ꍇ�͂�������폜
	if ($self->{codes}[0]->name eq 'direct'){
		print "Delete old \'direct\'\n";
		shift @{$self->{codes}};
	}
	
	
	unshift @{$self->{codes}}, kh_cod::a_code->new('direct',$direct);
}

# �����̎��s
sub search{
	my $self = shift;
	my %args = @_;
	
	# ��肠�����R�[�f�B���O
	foreach my $i (@{$args{selected}}){
		my $res_table = "ct_$args{tani}"."_code_$i";
		$self->{codes}[$i]->ready($args{tani}) or next;
		$self->{codes}[$i]->code($res_table) or next;
		if ($i->res_table){ push @{$self->{valid_codes}}, $i; }
	}
	
	# AND�����̎��ɁA0�R�[�h�����݂����ꍇ��return
	if (
		   ( $args{method} eq 'and' )
		&& ( @{$self->{valid_codes}} < @{$args{selected}} )
	) {
		return undef;
	}
	
	

}



1;