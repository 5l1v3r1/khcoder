package gui_hlist::linux;
use base qw(gui_hlist);
use strict;

sub _copy{
	gui_errormsg->open(
		msg => 'Linux��ǤΥ��ԡ��ϸ��ߥ��ݡ��Ȥ��Ƥ��ޤ���',
		type => 'msg',
	);
}
1;