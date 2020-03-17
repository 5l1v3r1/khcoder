# ���|��̌����Ă��郁�b�Z�[�W���Ɂu***not translated***�v��}������

use strict;
use YAML qw(LoadFile DumpFile);

# �`�F�b�N��i���{�ꁕ�p�ꃁ�b�Z�[�W�t�@�C���j
my $msg_en = LoadFile('../config/msg.en') or die;
my $msg_jp = LoadFile('../config/msg.jp') or die;

# �`�F�b�N�Ώ�
my @chk= (
	'msg.cn',
	'msg.es',
	'msg.kr',
);

foreach my $j (@chk){

	my $msg_ch = LoadFile('../config/'.$j) or die;

	# �����o��
	my $msg_out = '../config/'.$j;

	foreach my $i (sort keys %{$msg_en}){
		foreach my $h (sort keys %{$msg_en->{$i}}){
			my $ch = $msg_ch->{$i}{$h};
			
			if ( defined($ch) == 0 || $ch eq '***not translated***' ){
				print "missing: $i".'->'."$h, $msg_en->{$i}{$h}\n";
				$msg_ch->{$i}{$h} = '***not translated*** '.$msg_en->{$i}{$h}.' // '.$msg_jp->{$i}{$h};
			}
		}
	}

	DumpFile($msg_out, $msg_ch);
}