package gui_errormsg::mysql;
use strict;
use base qw(gui_errormsg);

sub get_msg{
	my $self = shift;
	my $msg = "MySQL�ǡ����١����ν����˼��Ԥ��ޤ�����\n";
	$msg .= "KH Coder��λ���ޤ���\n";
	
	if ($self->sql){
		$msg .= "\n";
		$msg .= $self->sql;
	}
	Jcode::convert(\$msg,'sjis');
	
	return $msg;
}

sub sql{
	my $self = shift;
	return $self->{sql};
}
1;