package jssdb_bench1;

sub plugin_config{
	return {
		name     => '�x���`�}�[�N�i�����@�\�j',
		menu_grp => 'JSSDB',
	};
}

sub exec{
	my $win = gui_window::word_ass->open;
	$win->{direct_w_e}->insert(  0, gui_window->gui_jchar('\'�Ƒ�\'')  );
	$win->{tani_obj}{raw_opt} = 'dan';
	
	use Benchmark;
	
	my $t0 = new Benchmark;
	
	$win->search;
	$win->net_calc;
	
	my $t1 = new Benchmark;

	print timestr( timediff($t1, $t0) );

}

1;


__END__

�E��PC�ł�32�`34�b�BR�փf�[�^��n���Ƃ��낪��Ԃ̃{�g���l�b�N�B
