package gui_window::cls_height::cod;
use strict;
use base qw(gui_window::cls_height);


sub win_title{
	my $self = shift;
	return $self->gui_jt('�����ɤΥ��饹����ʬ�ϡ�ʻ����','euc');
}

sub win_name{
	return 'w_cod_cls_height';
}

1;