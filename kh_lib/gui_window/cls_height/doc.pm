package gui_window::cls_height::doc;
use strict;
use base qw(gui_window::cls_height);


sub win_title{
	my $self = shift;
	return $self->gui_jt('ʸ��Υ��饹����ʬ�ϡ�ʻ����','euc');
}

sub win_name{
	return 'w_doc_cls_height';
}

1;