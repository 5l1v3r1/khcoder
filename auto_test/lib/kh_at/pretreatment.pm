package kh_at::pretreatment;
use base qw(kh_at);
use strict;

sub _exec_test{
	my $self = shift;
	
	# �u��̒��o���ʂ��m�F�v
	gui_window::morpho_check->open;
	my $win_src = $::main_gui->get('w_morpho_check');
	$win_src->entry->insert(0,gui_window->gui_jchar('���Ə؏�'));
	$win_src->search;
	
	# �u��̒��o���ʂ��m�F�F�ڍׁv
	$win_src->list->selectionSet(0);
	$win_src->detail;
	my $win_dtl = $::main_gui->get('w_morpho_detail');
	
	
	return $self;
}

sub test_name{
	return 'Pretreatment commands...';
}

1;