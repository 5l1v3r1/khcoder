package kh_csv;
use strict;

# CSV�t�@�C���쐻�̂��߂ɁA�u,"�v�Ɖ��s���G�X�P�[�v
# usage: kh_csv->value_conv("value");
sub value_conv{
	my $v = $_[1];
	if (
		   ($v =~ s/"/""/g )
		or ($v =~ /\r|\n|,/o )
	){
		$v = "\"$v\"";
	}
	return $v;
}

1;
