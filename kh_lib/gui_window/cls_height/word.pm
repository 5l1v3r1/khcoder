package gui_window::cls_height::word;
use strict;
use base qw(gui_window::cls_height);

sub win_title{
	my $self = shift;
	return $self->gui_jt('��и�Υ��饹����ʬ�ϡ�ʻ����','euc');
}

sub win_name{
	return 'w_word_cls_height';
}

sub _save{
	my $self = shift;
	my $path = shift;
	
	$self->{plots}{$self->{type}}{$self->{range}}->{command_f}
		=~ s/\nplot\(hcl.+?\nrect\.hclust\(hcl.+?\n/\n/;
	
	$self->{plots}{$self->{type}}{$self->{range}}->save($path) if $path;
}

1;